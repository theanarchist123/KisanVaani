"""
FastAPI main application for Enhanced RAG backend with VAPI integration
Advanced agricultural intelligence and voice interaction
"""

import os
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Request, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Dict, Any, List, Optional
from dotenv import load_dotenv

# Import enhanced modules
from enhanced_query_processor import get_enhanced_query_processor
from supabase_client import get_supabase_client
from enhanced_rag_processor import get_enhanced_rag_processor
from vapi_integration import get_vapi_integration

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Enhanced Pydantic models
class EnhancedQueryRequest(BaseModel):
    question: str = Field(..., description="The question to ask")
    max_chunks: int = Field(default=5, description="Maximum number of chunks to retrieve")
    similarity_threshold: float = Field(default=0.6, description="Minimum similarity threshold")
    user_context: Optional[Dict[str, Any]] = Field(default=None, description="User context (location, crops, etc.)")
    conversation_id: Optional[str] = Field(default=None, description="Conversation ID for context tracking")

class EnhancedQueryResponse(BaseModel):
    answer: str
    question: str
    chunks_used: int
    chunks: List[Dict[str, Any]]
    confidence: float
    suggestions: List[str]
    related_topics: List[str]
    urgency: str
    processing_metadata: Dict[str, Any]

class VAPIWebhookRequest(BaseModel):
    message: Dict[str, Any] = Field(..., description="VAPI webhook message")
    call: Optional[Dict[str, Any]] = Field(default=None, description="Call information")
    
class VAPIResponse(BaseModel):
    message: str = Field(..., description="Response message for VAPI")
    
class VAPICallRequest(BaseModel):
    phone_number: str = Field(..., description="Phone number to call")
    farmer_context: Optional[Dict[str, Any]] = Field(default=None, description="Farmer context information")

class SearchRequest(BaseModel):
    query: str = Field(..., description="Search query")
    limit: int = Field(default=10, description="Maximum number of results")

# Lifespan manager for startup/shutdown
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    logger.info("🚀 Starting Enhanced RAG Backend API with Agricultural Intelligence...")
    
    # Initialize enhanced components
    try:
        query_processor = get_enhanced_query_processor()
        vapi_integration = get_vapi_integration()
        logger.info("✅ All enhanced components initialized successfully")
    except Exception as e:
        logger.error(f"❌ Failed to initialize components: {str(e)}")
        raise
    
    yield
    
    logger.info("🔄 Shutting down Enhanced RAG Backend API...")

# Initialize FastAPI app
app = FastAPI(
    title="Enhanced RAG Backend API",
    description="Advanced Retrieval-Augmented Generation API with Agricultural Intelligence and VAPI integration",
    version="2.0.0",
    lifespan=lifespan
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health check endpoint
@app.get("/", response_model=Dict[str, Any])
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Enhanced RAG Backend API with Agricultural Intelligence is running",
        "version": "2.0.0",
        "features": ["Enhanced RAG", "Agricultural Intelligence", "VAPI Integration", "Context Awareness"],
        "endpoints": {
            "health": "/health",
            "query": "/query",
            "search": "/search",
            "chunks": "/chunks",
            "vapi_webhook": "/vapi-webhook",
            "vapi_call": "/vapi-call",
            "vapi_assistant": "/vapi-assistant"
        }
    }

@app.get("/health", response_model=Dict[str, Any])
async def health_check():
    """Enhanced health check endpoint"""
    try:
        query_processor = get_enhanced_query_processor()
        health_status = await query_processor.health_check()
        
        if health_status["overall"]:
            return {"status": "healthy", "details": health_status}
        else:
            raise HTTPException(status_code=503, detail={"status": "unhealthy", "details": health_status})
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        raise HTTPException(status_code=503, detail={"status": "error", "message": str(e)})

# Enhanced RAG query endpoint
@app.post("/query", response_model=EnhancedQueryResponse)
async def query_documents(request: EnhancedQueryRequest):
    """
    Process a question using Enhanced RAG pipeline with Agricultural Intelligence
    
    Features:
    - Advanced agricultural context understanding
    - Multi-strategy document retrieval
    - Intelligent chunk ranking
    - Personalized suggestions
    - Confidence scoring
    - Conversation context tracking
    """
    try:
        logger.info(f"Received enhanced query: {request.question[:100]}...")
        
        query_processor = get_enhanced_query_processor()
        response = await query_processor.process_query(
            question=request.question,
            max_chunks=request.max_chunks,
            similarity_threshold=request.similarity_threshold,
            user_context=request.user_context,
            conversation_id=request.conversation_id
        )
        
        return EnhancedQueryResponse(**response)
        
    except Exception as e:
        logger.error(f"Error processing enhanced query: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Search chunks endpoint (backward compatibility)
@app.post("/search", response_model=List[Dict[str, Any]])
async def search_chunks(request: dict):
    """
    Search for document chunks by semantic similarity
    
    Returns matching chunks without generating an answer
    """
    try:
        query = request.get("query", "")
        limit = request.get("limit", 10)
        
        logger.info(f"Searching chunks for: {query[:100]}...")
        
        query_processor = get_enhanced_query_processor()
        
        # Use enhanced search but return only chunks
        response = await query_processor.process_query(
            question=query,
            max_chunks=limit,
            similarity_threshold=0.5
        )
        
        return response.get("chunks", [])
        
    except Exception as e:
        logger.error(f"Error searching chunks: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Get random chunks endpoint
@app.get("/chunks", response_model=List[Dict[str, Any]])
async def get_chunks(limit: int = 5):
    """Get a sample of document chunks"""
    try:
        supabase_client = get_supabase_client()
        chunks = await supabase_client.get_random_chunks(limit=limit)
        return chunks
    except Exception as e:
        logger.error(f"Error getting chunks: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Enhanced VAPI webhook endpoint
@app.post("/vapi-webhook", response_model=VAPIResponse)
async def vapi_webhook(request: VAPIWebhookRequest, background_tasks: BackgroundTasks):
    """
    Enhanced webhook endpoint for VAPI voice assistant integration
    
    Features:
    - Agricultural intelligence in voice responses
    - Context-aware conversations
    - Farmer-friendly language processing
    - Multi-language support (Hindi/English)
    """
    try:
        logger.info("Received VAPI webhook request")
        
        # Process through VAPI integration
        vapi_integration = get_vapi_integration()
        response_data = await vapi_integration.process_vapi_webhook(request.dict())
        
        # Extract message for voice response
        message = response_data.get("result", response_data.get("message", ""))
        
        if not message:
            message = "मुझे समझने में कठिनाई हो रही है। कृपया अपना सवाल दोबारा पूछें।"
        
        # Log interaction in background
        background_tasks.add_task(log_vapi_interaction, request.dict(), response_data)
        
        return VAPIResponse(message=message)
        
    except Exception as e:
        logger.error(f"Error processing VAPI webhook: {str(e)}")
        return VAPIResponse(message="तकनीकी समस्या के कारण मैं आपकी मदद नहीं कर पा रहा। कृपया बाद में कोशिश करें।")

# VAPI call initiation endpoint
@app.post("/vapi-call", response_model=Dict[str, Any])
async def initiate_vapi_call(request: VAPICallRequest):
    """
    Initiate an agricultural consultation call through VAPI
    """
    try:
        logger.info(f"Initiating VAPI call to: {request.phone_number}")
        
        vapi_integration = get_vapi_integration()
        call_data = await vapi_integration.start_agricultural_call(
            phone_number=request.phone_number,
            farmer_context=request.farmer_context
        )
        
        return {
            "success": True,
            "call_id": call_data.get("id"),
            "status": "call_initiated",
            "message": "कॉल शुरू की गई है। कृपया प्रतीक्षा करें।"
        }
        
    except Exception as e:
        logger.error(f"Error initiating VAPI call: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# VAPI assistant creation endpoint
@app.post("/vapi-assistant", response_model=Dict[str, Any])
async def create_vapi_assistant():
    """
    Create a specialized agricultural assistant in VAPI
    """
    try:
        logger.info("Creating VAPI agricultural assistant")
        
        vapi_integration = get_vapi_integration()
        assistant_data = await vapi_integration.create_agricultural_assistant()
        
        return {
            "success": True,
            "assistant_id": assistant_data.get("id"),
            "name": assistant_data.get("name"),
            "message": "कृषि सहायक बनाया गया है।"
        }
        
    except Exception as e:
        logger.error(f"Error creating VAPI assistant: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# VAPI call analytics endpoint
@app.get("/vapi-analytics/{call_id}", response_model=Dict[str, Any])
async def get_vapi_analytics(call_id: str):
    """
    Get analytics for a VAPI agricultural call
    """
    try:
        vapi_integration = get_vapi_integration()
        analytics = await vapi_integration.get_call_analytics(call_id)
        
        return {
            "success": True,
            "call_id": call_id,
            "analytics": analytics
        }
        
    except Exception as e:
        logger.error(f"Error getting VAPI analytics: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Background task for logging
async def log_vapi_interaction(request_data: Dict[str, Any], response_data: Dict[str, Any]):
    """Log VAPI interactions for analytics and improvement"""
    try:
        logger.info(f"VAPI Interaction logged - Request type: {request_data.get('message', {}).get('type', 'unknown')}")
        # Here you could store interaction data for analytics
    except Exception as e:
        logger.error(f"Error logging VAPI interaction: {str(e)}")

# Development endpoint to test enhanced embedding generation
@app.post("/test-embedding")
async def test_embedding(text: str):
    """Test endpoint for enhanced embedding generation"""
    try:
        rag_processor = get_enhanced_rag_processor()
        embedding = await rag_processor.generate_embedding(text)
        return {
            "text": text,
            "embedding_dimension": len(embedding),
            "embedding_preview": embedding[:5],  # First 5 values
            "enhanced": True
        }
    except Exception as e:
        logger.error(f"Error testing embedding: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    debug = os.getenv("DEBUG", "True").lower() == "true"
    
    logger.info(f"Starting server on {host}:{port}")
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=debug,
        log_level="info"
    )
