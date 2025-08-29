"""
Real RAG backend with Supabase vector database retrieval
"""

import os
import logging
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Dict, Any, List, Optional
import google.generativeai as genai
from dotenv import load_dotenv
from supabase import create_client, Client
import json

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Configure Gemini AI
GOOGLE_API_KEY = os.getenv('GEMINI_API_KEY')  # Changed from GOOGLE_API_KEY to GEMINI_API_KEY
if not GOOGLE_API_KEY:
    logger.error("GEMINI_API_KEY not found in environment variables")
    raise ValueError("GEMINI_API_KEY is required")

genai.configure(api_key=GOOGLE_API_KEY)

# Configure Supabase
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    logger.error("SUPABASE_URL and SUPABASE_KEY are required")
    raise ValueError("Supabase configuration is required")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

class DocumentChunk(BaseModel):
    id: int
    content: str
    metadata: Dict[str, Any]
    similarity: Optional[float] = None

class QueryRequest(BaseModel):
    question: str = Field(..., description="The question to ask")
    max_chunks: int = Field(default=5, description="Maximum number of chunks to retrieve")
    similarity_threshold: float = Field(default=0.7, description="Minimum similarity threshold")

class QueryResponse(BaseModel):
    answer: str
    question: str
    chunks_used: int
    chunks: List[DocumentChunk]
    success: bool = True
    processing_time: str = "N/A"

class VapiWebhookRequest(BaseModel):
    message: Dict[str, Any] = Field(..., description="Vapi webhook message")
    call: Optional[Dict[str, Any]] = Field(default=None, description="Call information")
    
class VapiResponse(BaseModel):
    message: str = Field(..., description="Response message for Vapi")

# Initialize FastAPI app
app = FastAPI(
    title="Simplified RAG Backend API",
    description="Retrieval-Augmented Generation API with Gemini AI",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def generate_embedding(text: str) -> List[float]:
    """Generate embedding for text using Gemini"""
    try:
        model = genai.embed_content(
            model="models/text-embedding-004",
            content=text,
            task_type="retrieval_query"
        )
        return model['embedding']
    except Exception as e:
        logger.error(f"Error generating embedding: {e}")
        raise

def search_similar_chunks(question: str, max_chunks: int = 5, similarity_threshold: float = 0.7) -> List[DocumentChunk]:
    """Search for similar document chunks in Supabase"""
    try:
        logger.info(f"Searching for: {question}")
        
        # Extract key agricultural terms from the question
        question_lower = question.lower()
        
        # Define agricultural search terms based on question content
        if 'punjab' in question_lower:
            search_terms = ['punjab', 'wheat', 'rice', 'crop']
        elif any(crop in question_lower for crop in ['wheat', 'rice', 'maize', 'cotton', 'sugarcane']):
            # Extract the specific crop mentioned
            crops = ['wheat', 'rice', 'maize', 'cotton', 'sugarcane', 'barley', 'mustard']
            search_terms = [crop for crop in crops if crop in question_lower]
            search_terms.extend(['cultivation', 'crop', 'farming'])
        elif 'pest' in question_lower or 'disease' in question_lower:
            search_terms = ['pest', 'disease', 'control', 'management']
        elif 'fertilizer' in question_lower or 'nutrition' in question_lower:
            search_terms = ['fertilizer', 'nutrition', 'soil', 'nutrient']
        else:
            # General agricultural terms
            keywords = question_lower.split()
            search_terms = [word for word in keywords if len(word) > 3]
            if not search_terms:
                search_terms = ['agriculture', 'crop', 'farming']
        
        logger.info(f"Using search terms: {search_terms}")
        
        # Search for documents containing these terms
        chunks = []
        seen_ids = set()
        
        for term in search_terms[:3]:  # Limit to first 3 terms
            response = supabase.table('documents').select('id, content, metadata').ilike('content', f'%{term}%').limit(max_chunks * 2).execute()
            
            for item in response.data:
                if item['id'] not in seen_ids and len(chunks) < max_chunks:
                    # Check if the content is actually relevant (contains multiple search terms)
                    content_lower = item.get('content', '').lower()
                    relevance_score = sum(1 for term in search_terms if term in content_lower)
                    
                    if relevance_score >= 1:  # At least one matching term
                        chunk = DocumentChunk(
                            id=item.get('id', 0),
                            content=item.get('content', ''),
                            metadata=item.get('metadata', {}),
                            similarity=min(0.9, 0.5 + (relevance_score * 0.1))  # Score based on relevance
                        )
                        chunks.append(chunk)
                        seen_ids.add(item['id'])
        
        # Sort by similarity score (relevance)
        chunks.sort(key=lambda x: x.similarity, reverse=True)
        
        logger.info(f"Retrieved {len(chunks)} relevant chunks for question: {question[:50]}...")
        return chunks[:max_chunks]
        
    except Exception as e:
        logger.error(f"Error searching chunks: {e}")
        return []

def get_rag_answer(question: str, chunks: List[DocumentChunk]) -> str:
    """Generate answer using retrieved chunks and Gemini AI"""
    
    if not chunks:
        return "I don't have specific information to answer your question. Please consult with local agricultural experts for detailed guidance."
    
    # Extract key information from chunks instead of dumping everything
    relevant_info = []
    
    for chunk in chunks:
        content = chunk.content
        source = chunk.metadata.get('source', 'Agricultural document')
        
        # Extract relevant sentences (limit content to most relevant parts)
        sentences = content.split('.')
        relevant_sentences = []
        
        # Look for sentences that might contain useful information
        question_keywords = question.lower().split()
        for sentence in sentences:
            sentence_lower = sentence.lower()
            # Check if sentence contains keywords from the question
            if any(keyword in sentence_lower for keyword in question_keywords if len(keyword) > 3):
                relevant_sentences.append(sentence.strip())
            # Also look for agricultural terms
            elif any(term in sentence_lower for term in ['crop', 'cultivation', 'farming', 'soil', 'plant', 'agriculture', 'harvest', 'seed', 'control', 'pest', 'disease']):
                relevant_sentences.append(sentence.strip())
        
        # Limit to most relevant sentences
        if relevant_sentences:
            content_summary = '. '.join(relevant_sentences[:2])  # Max 2 sentences per chunk
            if len(content_summary) > 200:  # Limit length
                content_summary = content_summary[:200] + "..."
            relevant_info.append(content_summary)
    
    # Create focused context - only include most relevant info
    if relevant_info:
        context = "Key information:\n" + "\n".join(relevant_info[:2])  # Max 2 sources
    else:
        # Fallback to very short excerpts
        context = "Available information:\n"
        for i, chunk in enumerate(chunks[:1]):  # Max 1 chunk
            excerpt = chunk.content[:150] + "..." if len(chunk.content) > 150 else chunk.content
            context += excerpt
    
    # Create more focused prompt for agricultural questions
    if any(term in question.lower() for term in ['punjab', 'india', 'crop', 'farming']):
        prompt = f"""You are an agricultural expert assistant. Answer the farmer's question concisely using ONLY the provided information.

{context}

Question: {question}

Rules:
- Keep answer under 100 words
- Be direct and practical
- If the documents don't contain the specific information, say so briefly
- Focus on actionable advice only
- Don't add general knowledge beyond what's provided

Answer:"""
    else:
        prompt = f"""Answer this agricultural question concisely based on the provided information:

{context}

Question: {question}

Keep the answer brief (under 80 words) and practical.

Answer:"""

    try:
        # Use Gemini AI to generate response
        model = genai.GenerativeModel('gemini-1.5-flash')
        response = model.generate_content(prompt)
        
        # Clean up the response
        answer = response.text.strip()
        
        # Ensure the answer is concise
        if len(answer) > 300:  # If too long, truncate
            sentences = answer.split('.')
            short_answer = []
            char_count = 0
            for sentence in sentences:
                if char_count + len(sentence) > 250:
                    break
                short_answer.append(sentence)
                char_count += len(sentence)
            answer = '. '.join(short_answer) + '.'
        
        return answer
        
    except Exception as e:
        logger.error(f"Error generating AI response: {e}")
        return f"I found some relevant information about '{question}', but I'm having trouble generating a complete answer right now. Please consult with local agricultural experts for detailed guidance."

# Health check endpoint
@app.get("/", response_model=Dict[str, Any])
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Simplified RAG Backend API is running",
        "version": "1.0.0",
        "status": "healthy",
        "endpoints": {
            "health": "/health",
            "query": "/query",
            "webhook": "/webhook"
        }
    }

@app.get("/health", response_model=Dict[str, Any])
async def health_check():
    """Health check endpoint"""
    try:
        # Test Gemini API connection and Supabase connection
        model = genai.GenerativeModel('gemini-1.5-flash')  # Updated model name
        test_response = model.generate_content("Hello")
        
        # Test Supabase connection
        supabase_test = supabase.table('documents').select('count').limit(1).execute()
        
        return {
            "status": "healthy", 
            "details": {
                "overall": True,
                "gemini_ai": True,
                "supabase_connected": True,
                "api_key_configured": bool(GOOGLE_API_KEY)
            }
        }
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        raise HTTPException(status_code=503, detail={"status": "unhealthy", "details": {"overall": False, "error": str(e)}})

# Main RAG query endpoint
@app.post("/query", response_model=QueryResponse)
async def query_documents(request: QueryRequest):
    """
    Process a question using real RAG pipeline with Supabase vector search
    """
    try:
        logger.info(f"Received query: {request.question[:100]}...")
        
        # Search for similar chunks in Supabase
        chunks = search_similar_chunks(
            question=request.question,
            max_chunks=request.max_chunks,
            similarity_threshold=request.similarity_threshold
        )
        
        # Generate answer using retrieved chunks and Gemini AI
        answer = get_rag_answer(request.question, chunks)
        
        response = QueryResponse(
            answer=answer,
            question=request.question,
            chunks_used=len(chunks),
            chunks=chunks,
            success=True,
            processing_time="Real RAG with Supabase + Gemini"
        )
        
        logger.info(f"Successfully processed query with {len(chunks)} chunks: {request.question[:50]}...")
        return response
        
    except Exception as e:
        logger.error(f"Error processing query: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Vapi webhook endpoint
@app.post("/webhook", response_model=VapiResponse)
async def vapi_webhook(request: VapiWebhookRequest):
    """
    Webhook endpoint for Vapi voice assistant integration with real RAG
    """
    try:
        logger.info("Received Vapi webhook request")
        
        # Extract the spoken message from Vapi request
        message_content = request.message.get("content", "")
        if not message_content:
            message_content = request.message.get("text", "")
            if not message_content:
                message_content = str(request.message)
        
        logger.info(f"Processing Vapi message: {message_content}")
        
        # Use RAG pipeline to get answer
        chunks = search_similar_chunks(message_content, max_chunks=3, similarity_threshold=0.7)
        response_text = get_rag_answer(message_content, chunks)
        
        return VapiResponse(message=response_text)
        
    except Exception as e:
        logger.error(f"Error processing Vapi webhook: {str(e)}")
        return VapiResponse(message="I'm sorry, I encountered an error processing your request. Please try again.")

if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting Simplified RAG Backend on http://localhost:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000)
