"""
Debug RAG server with detailed error handling
"""
import os
import json
import asyncio
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, Any, List
from dotenv import load_dotenv
import httpx

load_dotenv()

app = FastAPI(title="Debug RAG Backend")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

class QueryRequest(BaseModel):
    question: str
    max_chunks: int = 5

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_KEY')
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')

@app.get("/health")
async def health_check():
    """Health check with detailed status"""
    status = {
        "status": "running",
        "supabase_url": SUPABASE_URL,
        "has_supabase_key": bool(SUPABASE_KEY),
        "has_gemini_key": bool(GEMINI_API_KEY),
        "supabase_accessible": False,
        "documents_accessible": False
    }
    
    if SUPABASE_URL and SUPABASE_KEY:
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}'
        }
        
        try:
            async with httpx.AsyncClient() as client:
                # Test basic API access
                response = await client.get(f"{SUPABASE_URL}/rest/v1/", headers=headers, timeout=5.0)
                status["supabase_accessible"] = response.status_code == 200
                status["api_status_code"] = response.status_code
                
                if response.status_code == 401:
                    status["error"] = "Unauthorized - Need collaborator access"
                elif response.status_code != 200:
                    status["error"] = f"API error: {response.status_code}"
                
                # Test documents table access
                if status["supabase_accessible"]:
                    doc_response = await client.get(f"{SUPABASE_URL}/rest/v1/documents", headers=headers, timeout=5.0)
                    status["documents_accessible"] = doc_response.status_code == 200
                    status["documents_status_code"] = doc_response.status_code
                    
                    if doc_response.status_code == 200:
                        data = doc_response.json()
                        status["documents_count"] = len(data)
                    elif doc_response.status_code == 401:
                        status["documents_error"] = "No permission to read documents table"
                    else:
                        status["documents_error"] = f"Documents access error: {doc_response.status_code}"
                        
        except Exception as e:
            status["connection_error"] = str(e)
    
    return status

@app.get("/debug")
async def debug_info():
    """Debug information"""
    return {
        "environment": {
            "supabase_url": SUPABASE_URL,
            "supabase_key_length": len(SUPABASE_KEY) if SUPABASE_KEY else 0,
            "gemini_key_length": len(GEMINI_API_KEY) if GEMINI_API_KEY else 0
        },
        "message": "Check /health for connection status"
    }

@app.post("/query")
async def query_rag(request: QueryRequest):
    """Query with fallback to demo data if Supabase unavailable"""
    
    # Try Supabase first
    if SUPABASE_URL and SUPABASE_KEY:
        headers = {
            'apikey': SUPABASE_KEY,
            'Authorization': f'Bearer {SUPABASE_KEY}'
        }
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(f"{SUPABASE_URL}/rest/v1/documents", headers=headers, timeout=5.0)
                
                if response.status_code == 200:
                    documents = response.json()
                    
                    # Simple search
                    relevant_docs = []
                    query_lower = request.question.lower()
                    
                    for doc in documents:
                        content = doc.get('content', '').lower()
                        if any(word in content for word in query_lower.split()):
                            relevant_docs.append(doc)
                    
                    if relevant_docs:
                        # Use first relevant document
                        context = relevant_docs[0].get('content', '')[:500]
                        answer = f"Based on the agricultural knowledge base: {context}..."
                        
                        return {
                            "answer": answer,
                            "question": request.question,
                            "chunks_used": len(relevant_docs),
                            "source": "supabase",
                            "relevant_chunks": relevant_docs[:request.max_chunks]
                        }
        except Exception as e:
            pass  # Fall through to demo response
    
    # Fallback to demo response
    demo_responses = {
        "rice": "Rice cultivation best practices include: 1) Proper water management with alternate wetting and drying, 2) Use of certified seeds, 3) Balanced fertilization with NPK ratio 4:2:1, 4) Integrated pest management, 5) Optimal spacing of 20x15 cm for transplanted rice.",
        "wheat": "Wheat farming requires: 1) Well-drained loamy soil, 2) Sowing in November-December, 3) Irrigation at crown root, tillering, flowering, and grain filling stages, 4) Fertilizer application of 120:60:40 NPK kg/ha, 5) Harvesting when moisture content is 20-25%.",
        "organic": "Organic farming principles: 1) Use of organic fertilizers like compost and vermicompost, 2) Biological pest control methods, 3) Crop rotation to maintain soil health, 4) Avoiding synthetic chemicals, 5) Maintaining biodiversity in farming systems.",
        "crop yield": "To improve crop yield: 1) Use high-yielding varieties, 2) Ensure proper nutrition management, 3) Maintain optimal plant population, 4) Control weeds, pests, and diseases, 5) Provide adequate irrigation, 6) Use modern farming techniques."
    }
    
    # Find relevant demo response
    query_lower = request.question.lower()
    for key, response in demo_responses.items():
        if key in query_lower:
            return {
                "answer": response,
                "question": request.question,
                "chunks_used": 1,
                "source": "demo_fallback",
                "relevant_chunks": []
            }
    
    # Default response
    return {
        "answer": "I understand you're asking about agriculture. While I don't have specific information about your question in my knowledge base, I recommend consulting with local agricultural extension services or agricultural universities for detailed guidance on farming practices.",
        "question": request.question,
        "chunks_used": 0,
        "source": "default_fallback",
        "relevant_chunks": []
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
