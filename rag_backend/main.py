"""
FastAPI main application for RAG backend with Vapi integration
"""

import os
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Request, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Dict, Any, List, Optional
from dotenv import load_dotenv

# Import custom modules
from query import get_query_processor
from supabase_client import get_supabase_client
from rag_processor import get_rag_processor

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Pydantic models for request/response
class QueryRequest(BaseModel):
    question: str = Field(..., description="The question to ask")
    max_chunks: int = Field(default=5, description="Maximum number of chunks to retrieve")
    similarity_threshold: float = Field(default=0.7, description="Minimum similarity threshold")

class QueryResponse(BaseModel):
    answer: str
    question: str
    chunks_used: int
    chunks: List[Dict[str, Any]]
    query_embedding_dimension: Optional[int] = None
    similarity_threshold: Optional[float] = None
    max_chunks_requested: Optional[int] = None

class SearchRequest(BaseModel):
    query: str = Field(..., description="Search query")
    limit: int = Field(default=10, description="Maximum number of results")

class VapiWebhookRequest(BaseModel):
    message: Dict[str, Any] = Field(..., description="Vapi webhook message")
    call: Optional[Dict[str, Any]] = Field(default=None, description="Call information")
    
class VapiResponse(BaseModel):
    message: str = Field(..., description="Response message for Vapi")

# Lifespan manager for startup/shutdown
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    logger.info("🚀 Starting RAG Backend API...")
    
    # Initialize components
    try:
        query_processor = get_query_processor()
        logger.info("✅ All components initialized successfully")
    except Exception as e:
        logger.error(f"❌ Failed to initialize components: {str(e)}")
        raise
    
    yield
    
    logger.info("🔄 Shutting down RAG Backend API...")

# Initialize FastAPI app
app = FastAPI(
    title="RAG Backend API",
    description="Retrieval-Augmented Generation API with Vapi integration",
    version="1.0.0",
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
        "message": "RAG Backend API is running",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "query": "/query",
            "search": "/search",
            "chunks": "/chunks",
            "webhook": "/webhook"
        }
    }

@app.get("/health", response_model=Dict[str, Any])
async def health_check():
    """Health check endpoint"""
    try:
        query_processor = get_query_processor()
        health_status = await query_processor.health_check()
        
        if health_status["overall"]:
            return {"status": "healthy", "details": health_status}
        else:
            raise HTTPException(status_code=503, detail={"status": "unhealthy", "details": health_status})
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        raise HTTPException(status_code=503, detail={"status": "error", "message": str(e)})

# Main RAG query endpoint
@app.post("/query", response_model=QueryResponse)
async def query_documents(request: QueryRequest):
    """
    Process a question using RAG pipeline
    
    This endpoint:
    1. Generates embeddings for the question
    2. Searches for similar document chunks
    3. Uses Gemini to generate an answer based on retrieved context
    """
    try:
        logger.info(f"Received query: {request.question[:100]}...")
        
        query_processor = get_query_processor()
        response = await query_processor.process_query(
            question=request.question,
            max_chunks=request.max_chunks,
            similarity_threshold=request.similarity_threshold
        )
        
        return QueryResponse(**response)
        
    except Exception as e:
        logger.error(f"Error processing query: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Search chunks endpoint
@app.post("/search", response_model=List[Dict[str, Any]])
async def search_chunks(request: SearchRequest):
    """
    Search for document chunks by semantic similarity
    
    Returns matching chunks without generating an answer
    """
    try:
        logger.info(f"Searching chunks for: {request.query[:100]}...")
        
        query_processor = get_query_processor()
        chunks = await query_processor.search_chunks(
            query=request.query,
            limit=request.limit
        )
        
        return chunks
        
    except Exception as e:
        logger.error(f"Error searching chunks: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Get random chunks endpoint
@app.get("/chunks", response_model=List[Dict[str, Any]])
async def get_chunks(limit: int = 5):
    """Get a sample of document chunks"""
    try:
        query_processor = get_query_processor()
        chunks = await query_processor.get_random_chunks(limit=limit)
        return chunks
    except Exception as e:
        logger.error(f"Error getting chunks: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Vapi webhook endpoint
@app.post("/webhook", response_model=VapiResponse)
async def vapi_webhook(request: VapiWebhookRequest, background_tasks: BackgroundTasks):
    """
    Webhook endpoint for Vapi voice assistant integration
    
    Processes spoken questions and returns AI-generated answers
    """
    try:
        logger.info("Received Vapi webhook request")
        
        # Extract the spoken message from Vapi request
        message_content = request.message.get("content", "")
        if not message_content:
            # Try alternative message structures
            message_content = request.message.get("text", "")
            if not message_content:
                message_content = str(request.message)
        
        if not message_content or message_content.strip() == "":
            return VapiResponse(message="I didn't catch that. Could you please repeat your question?")
        
        logger.info(f"Processing Vapi question: {message_content[:100]}...")
        
        # Process the question through RAG pipeline
        query_processor = get_query_processor()
        response = await query_processor.process_query(
            question=message_content,
            max_chunks=3,  # Limit for voice responses
            similarity_threshold=0.6  # Lower threshold for voice
        )
        
        # Return the answer for Vapi to speak
        answer = response.get("answer", "I'm sorry, I couldn't process your question.")
        
        # Optionally log the interaction in background
        background_tasks.add_task(log_vapi_interaction, message_content, answer)
        
        return VapiResponse(message=answer)
        
    except Exception as e:
        logger.error(f"Error processing Vapi webhook: {str(e)}")
        return VapiResponse(message="I'm experiencing technical difficulties. Please try again.")

# Background task for logging
async def log_vapi_interaction(question: str, answer: str):
    """Log Vapi interactions for analytics"""
    try:
        logger.info(f"Vapi Interaction - Q: {question[:50]}... A: {answer[:50]}...")
    except Exception as e:
        logger.error(f"Error logging Vapi interaction: {str(e)}")

# Development endpoint to test embedding generation
@app.post("/test-embedding")
async def test_embedding(text: str):
    """Test endpoint for embedding generation"""
    try:
        rag_processor = get_rag_processor()
        embedding = await rag_processor.generate_embedding(text)
        return {
            "text": text,
            "embedding_dimension": len(embedding),
            "embedding_preview": embedding[:5]  # First 5 values
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
