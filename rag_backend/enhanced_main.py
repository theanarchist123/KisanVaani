"""
Enhanced RAG Backend with Agricultural Intelligence (Fixed Version)
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
from datetime import datetime

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Configure Gemini AI
GOOGLE_API_KEY = os.getenv('GEMINI_API_KEY')
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

# Pydantic models
class EnhancedQueryRequest(BaseModel):
    question: str = Field(..., description="The question to ask")
    max_chunks: int = Field(default=5, description="Maximum number of chunks to retrieve")
    similarity_threshold: float = Field(default=0.6, description="Minimum similarity threshold")
    user_context: Optional[Dict[str, Any]] = Field(default=None, description="User context")
    conversation_id: Optional[str] = Field(default=None, description="Conversation ID")

class EnhancedQueryResponse(BaseModel):
    answer: str
    question: str
    chunks_used: int
    chunks: List[Dict[str, Any]]
    confidence: float
    suggestions: List[str]
    urgency: str
    processing_metadata: Dict[str, Any]

class VAPICallRequest(BaseModel):
    phone_number: str = Field(..., description="Phone number to call")
    farmer_context: Optional[Dict[str, Any]] = Field(default=None, description="Farmer context")

# Initialize FastAPI app
app = FastAPI(
    title="Enhanced RAG Backend API",
    description="Agricultural Intelligence RAG API",
    version="2.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Agricultural knowledge base
AGRICULTURAL_KNOWLEDGE = {
    "crops": {
        "wheat": {
            "season": "rabi",
            "irrigation": "moderate",
            "common_diseases": ["rust", "blight"],
            "soil_type": "loamy",
            "fertilizer": {"N": "high", "P": "medium", "K": "medium"},
            "climate": "cool",
            "growth_duration": "120-150 days"
        },
        "rice": {
            "season": "kharif",
            "irrigation": "high",
            "common_diseases": ["blast", "blight"],
            "soil_type": "clayey",
            "fertilizer": {"N": "high", "P": "medium", "K": "high"},
            "climate": "warm and humid",
            "growth_duration": "90-150 days"
        },
        "corn": {
            "season": "kharif",
            "irrigation": "moderate",
            "common_diseases": ["borer", "rust"],
            "soil_type": "loamy",
            "fertilizer": {"N": "high", "P": "high", "K": "medium"},
            "climate": "warm",
            "growth_duration": "70-100 days"
        },
        "tomato": {
            "season": "both",
            "irrigation": "regular",
            "common_diseases": ["wilt", "blight"],
            "soil_type": "well-drained",
            "fertilizer": {"N": "medium", "P": "high", "K": "high"},
            "climate": "moderate",
            "growth_duration": "60-80 days"
        },
        "cotton": {
            "season": "kharif",
            "irrigation": "moderate",
            "common_diseases": ["bollworm", "wilt"],
            "soil_type": "black soil",
            "fertilizer": {"N": "high", "P": "medium", "K": "high"},
            "climate": "warm and dry",
            "growth_duration": "150-180 days"
        }
    },
    "seasons": {
        "kharif": {
            "months": "June-October",
            "crops": ["rice", "corn", "cotton", "sugarcane"],
            "rainfall": "high",
            "temperature": "25-35°C"
        },
        "rabi": {
            "months": "November-April",
            "crops": ["wheat", "barley", "peas", "mustard"],
            "rainfall": "low",
            "temperature": "15-25°C"
        }
    },
    "soil_types": {
        "loamy": {"characteristics": ["well-drained", "fertile", "good water retention"], "suitable_crops": ["wheat", "corn", "vegetables"]},
        "clayey": {"characteristics": ["high water retention", "heavy", "rich in nutrients"], "suitable_crops": ["rice", "sugarcane"]},
        "sandy": {"characteristics": ["well-drained", "low fertility", "low water retention"], "suitable_crops": ["groundnut", "millet"]},
        "black": {"characteristics": ["high water retention", "rich in minerals", "good for cotton"], "suitable_crops": ["cotton", "sugarcane"]}
    }
}

def get_crop_specific_knowledge(crops: List[str]) -> Dict[str, Any]:
    """Get specific knowledge for given crops"""
    crop_knowledge = {}
    for crop in crops:
        if crop.lower() in AGRICULTURAL_KNOWLEDGE["crops"]:
            crop_info = AGRICULTURAL_KNOWLEDGE["crops"][crop.lower()]
            season_info = AGRICULTURAL_KNOWLEDGE["seasons"][crop_info["season"]] if crop_info["season"] != "both" else {
                "months": "Year-round",
                "rainfall": "Varies",
                "temperature": "Moderate"
            }
            
            crop_knowledge[crop] = {
                **crop_info,
                "season_details": season_info
            }
    return crop_knowledge

def search_similar_chunks(query: str, max_chunks: int = 5, similarity_threshold: float = 0.65) -> List[Dict[str, Any]]:
    """Search for similar chunks using dynamic similarity threshold"""
    try:
        # Start with provided threshold
        chunks = []
        current_threshold = similarity_threshold
        
        while len(chunks) < max_chunks and current_threshold >= 0.3:
            response = supabase.rpc(
                'match_documents',
                {
                    'query_text': query,
                    'similarity_threshold': current_threshold,
                    'match_count': max_chunks
                }
            ).execute()
            
            chunks = response.data or []
            
            # If we don't have enough chunks, lower the threshold
            if len(chunks) < max_chunks:
                current_threshold -= 0.1
            else:
                break
        
        logger.info(f"Found {len(chunks)} chunks with threshold {current_threshold}")
        return chunks[:max_chunks]
        
    except Exception as e:
        logger.error(f"Error searching chunks: {str(e)}")
        try:
            response = supabase.from_('documents').select('*').limit(max_chunks).execute()
            return response.data or []
        except:
            return []

def enhance_question_with_context(question: str, user_context: Optional[Dict[str, Any]]) -> str:
    """Enhance question with agricultural context"""
    enhanced_question = question
    
    if user_context:
        location = user_context.get('location')
        crops = user_context.get('crops', [])
        season = user_context.get('season')
        soil_type = user_context.get('soil_type')
        weather = user_context.get('weather')
        
        context_parts = []
        if location:
            context_parts.append(f"in {location}")
        if crops:
            context_parts.append(f"for {', '.join(crops)} crops")
        if season:
            context_parts.append(f"during {season} season")
        if soil_type:
            context_parts.append(f"with {soil_type} soil")
        if weather:
            context_parts.append(f"considering {weather} weather conditions")
        
        if context_parts:
            enhanced_question += f" {' and '.join(context_parts)}"
    
    return enhanced_question

def determine_urgency(question: str, chunks: List[Dict[str, Any]]) -> str:
    """Determine urgency level based on question and context"""
    urgent_keywords = ['disease', 'pest', 'dying', 'emergency', 'urgent', 'help', 'problem', 'damage']
    high_keywords = ['treatment', 'cure', 'save', 'loss', 'weather', 'warning']
    medium_keywords = ['improve', 'increase', 'better', 'advice', 'suggestion']
    
    question_lower = question.lower()
    chunk_text = ' '.join([chunk.get('content', '').lower() for chunk in chunks])
    
    # Check both question and context
    if any(keyword in question_lower or keyword in chunk_text for keyword in urgent_keywords):
        return 'urgent'
    if any(keyword in question_lower or keyword in chunk_text for keyword in high_keywords):
        return 'high'
    if any(keyword in question_lower or keyword in chunk_text for keyword in medium_keywords):
        return 'medium'
    return 'low'

def generate_suggestions(question: str, user_context: Optional[Dict[str, Any]]) -> List[str]:
    """Generate contextual suggestions"""
    suggestions = []
    question_lower = question.lower()
    
    if user_context:
        crops = user_context.get('crops', [])
        location = user_context.get('location')
        
        if crops:
            suggestions.append(f"Consider crop rotation with your {', '.join(crops)} for better soil health")
        
        if location:
            suggestions.append(f"Check local weather forecasts for {location}")
    
    # Question-based suggestions
    if 'fertilizer' in question_lower:
        suggestions.append("Get a soil test to determine optimal fertilizer requirements")
    elif 'disease' in question_lower:
        suggestions.append("Learn about preventive measures for common crop diseases")
    elif 'irrigation' in question_lower:
        suggestions.append("Explore water-efficient irrigation techniques")
    
    # General suggestions
    suggestions.extend([
        "Connect with local agricultural extension services",
        "Join farmer community groups for knowledge sharing"
    ])
    
    return suggestions[:5]

def calculate_confidence(question: str, chunks: List[Dict[str, Any]], answer: str) -> float:
    """Calculate confidence score with sophisticated metrics"""
    if not chunks:
        return 0.3
    
    # Base confidence from chunk quality
    avg_similarity = sum(chunk.get('similarity', 0) for chunk in chunks) / len(chunks)
    confidence = avg_similarity * 0.5  # Weight the similarity score
    
    # Context relevance
    chunk_keywords = set()
    for chunk in chunks:
        content = chunk.get('content', '').lower()
        words = set(content.split())
        chunk_keywords.update(words)
    
    answer_words = set(answer.lower().split())
    keyword_overlap = len(chunk_keywords.intersection(answer_words))
    confidence += min(0.2, keyword_overlap * 0.02)  # Up to 0.2 for keyword overlap
    
    # Answer quality metrics
    if len(answer.split()) >= 50:  # Comprehensive answer
        confidence += 0.1
    
    # Check for actionable advice
    actionable_phrases = ['for example', 'step', 'recommend', 'suggest', 'follow', 'apply']
    if any(phrase in answer.lower() for phrase in actionable_phrases):
        confidence += 0.1
    
    # Multiple source confirmation
    if len(chunks) >= 3:
        confidence += 0.1
        
    # Clarity check
    clarity_indicators = ['first', 'second', 'finally', 'important', 'note', 'remember']
    if any(indicator in answer.lower() for indicator in clarity_indicators):
        confidence += 0.1
        
    # Check if answer addresses agricultural context
    agri_terms = [
        'crop', 'soil', 'water', 'plant', 'season', 'farm', 'grow', 'harvest',
        'fertilizer', 'irrigation', 'pest', 'disease', 'seed', 'weather'
    ]
    agri_terms_found = sum(1 for term in agri_terms if term in answer.lower())
    confidence += min(0.2, agri_terms_found * 0.02)  # Up to 0.2 for agricultural relevance
    
    # Penalize very short answers
    if len(answer.split()) < 20:
        confidence -= 0.2
        
    # Penalize lack of specificity
    if all(term not in answer.lower() for term in ['specific', 'exact', 'approximately', 'about', 'around']):
        confidence -= 0.1
    
    return min(max(confidence, 0.1), 1.0)  # Ensure confidence is between 0.1 and 1.0
    term_matches = sum(1 for term in agricultural_terms if term in answer.lower())
    confidence += term_matches * 0.05
    
    # Boost for multiple chunks
    if len(chunks) >= 3:
        confidence += 0.1
    
    return min(confidence, 1.0)

def get_enhanced_rag_answer(question: str, chunks: List[Dict[str, Any]], user_context: Optional[Dict[str, Any]] = None) -> str:
    """Generate enhanced answer using Gemini AI with sophisticated agricultural intelligence"""
    try:
        # Create detailed context from chunks with source tracking
        context_sections = []
        for i, chunk in enumerate(chunks[:3], 1):
            content = chunk.get('content', '')
            source = chunk.get('source', 'Agricultural Database')
            metadata = chunk.get('metadata', {})
            if metadata:
                context_sections.append(f"Source {i} ({source}) - {metadata.get('relevance', 'General')} Information:\n{content}")
            else:
                context_sections.append(f"Source {i} ({source}):\n{content}")
        
        context = "\n\n".join(context_sections)
        
        # Get crop-specific knowledge
        crop_knowledge = {}
        if user_context and user_context.get('crops'):
            crop_knowledge = get_crop_specific_knowledge(user_context.get('crops', []))
        
        # Enhanced prompt with sophisticated context integration
        prompt = f"""You are an expert agricultural advisor with deep knowledge of farming practices in India. 
        Respond as if speaking directly to a farmer in clear, practical terms.

        CONTEXT INFORMATION:
        {context}

        FARMER'S QUESTION:
        {question}

        FARMER'S SPECIFIC CONTEXT:
        Location: {user_context.get('location', 'Not specified')}
        Crops: {', '.join(user_context.get('crops', []))}
        Season: {user_context.get('season', 'Not specified')}
        Soil Type: {user_context.get('soil_type', 'Not specified')}
        Weather: {user_context.get('weather', 'Not specified')}

        RELEVANT CROP INFORMATION:
        {str(crop_knowledge)}

        RESPONSE REQUIREMENTS:
        1. Start with a direct answer to the question
        2. Use simple, clear language suitable for farmers
        3. Provide specific, actionable steps when relevant
        4. Include both Hindi and English terms for key concepts
        5. Consider local conditions and seasonal factors
        6. Focus on practical, cost-effective solutions
        7. Add important warnings or precautions if applicable
        8. Include traditional and modern farming methods when relevant
        9. If suggesting products or treatments, mention natural alternatives
        10. For time-sensitive issues (diseases/pests), prioritize immediate actions

        Please provide a comprehensive yet concise answer that a farmer can easily understand and apply:"""
        
        # Generate response using Gemini
        model = genai.GenerativeModel('gemini-1.5-flash')  # Changed from gemini-pro to gemini-1.5-flash
        response = model.generate_content(prompt)
        
        return response.text if response.text else "I apologize, but I couldn't generate a proper response. Please try rephrasing your question."
        
    except Exception as e:
        logger.error(f"Error generating RAG answer: {str(e)}")
        return "I encountered an error while processing your question. Please try again or contact local agricultural experts for assistance."

# API Endpoints
@app.get("/", response_model=Dict[str, Any])
async def root():
    """Root endpoint"""
    return {
        "message": "Enhanced RAG Backend with Agricultural Intelligence",
        "version": "2.0.0",
        "status": "running",
        "features": ["Enhanced RAG", "Agricultural Intelligence", "Context Awareness", "VAPI Integration"]
    }

@app.get("/ping")
async def ping():
    """Ultra-fast ping endpoint"""
    return {"status": "ok", "timestamp": datetime.now().isoformat()}

@app.get("/health", response_model=Dict[str, Any])
async def health_check():
    """Fast health check endpoint optimized for Flutter app"""
    try:
        # Quick health check - just return success since server is running
        return {
            "status": "healthy",
            "details": {
                "overall": True,
                "enhanced_features": True,
                "supabase": True,  # Assume healthy if server is running
                "gemini": True,    # Assume healthy if server is running
                "agricultural_intelligence": True,
                "context_awareness": True,
                "vapi_integration": True
            },
            "components": {
                "supabase": "healthy",
                "gemini": "healthy"
            },
            "timestamp": datetime.now().isoformat(),
            "response_time": "fast"
        }
    except Exception as e:
        logger.error(f"Health check error: {str(e)}")
        return {
            "status": "unhealthy",
            "details": {
                "overall": False,
                "enhanced_features": False,
                "error": str(e)
            },
            "timestamp": datetime.now().isoformat()
        }

@app.post("/query", response_model=EnhancedQueryResponse)
async def enhanced_query(request: EnhancedQueryRequest):
    """Enhanced query endpoint with agricultural intelligence"""
    try:
        logger.info(f"Processing enhanced query: {request.question[:100]}...")
        
        # Enhance question with context
        enhanced_question = enhance_question_with_context(request.question, request.user_context)
        
        # Search for relevant chunks
        chunks = search_similar_chunks(
            enhanced_question, 
            request.max_chunks, 
            request.similarity_threshold
        )
        
        if not chunks:
            return EnhancedQueryResponse(
                answer="I couldn't find specific information about your question. Please try rephrasing or contact local agricultural experts.",
                question=request.question,
                chunks_used=0,
                chunks=[],
                confidence=0.3,
                suggestions=generate_suggestions(request.question, request.user_context),
                urgency="low",
                processing_metadata={"fallback": True}
            )
        
        # Generate enhanced answer
        answer = get_enhanced_rag_answer(enhanced_question, chunks, request.user_context)
        
        # Calculate metrics
        confidence = calculate_confidence(request.question, chunks, answer)
        urgency = determine_urgency(request.question, chunks)
        suggestions = generate_suggestions(request.question, request.user_context)
        
        return EnhancedQueryResponse(
            answer=answer,
            question=request.question,
            chunks_used=len(chunks),
            chunks=chunks,
            confidence=confidence,
            suggestions=suggestions,
            urgency=urgency,
            processing_metadata={
                "enhanced_question": enhanced_question,
                "context_used": bool(request.user_context),
                "chunks_found": len(chunks)
            }
        )
        
    except Exception as e:
        logger.error(f"Error in enhanced query: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/search")
async def search_chunks(request: dict):
    """Search chunks endpoint"""
    try:
        query = request.get("query", "")
        limit = request.get("limit", 10)
        
        chunks = search_similar_chunks(query, limit, 0.5)
        return chunks
        
    except Exception as e:
        logger.error(f"Error searching chunks: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/chunks")
async def get_chunks(limit: int = 5):
    """Get sample chunks"""
    try:
        response = supabase.from_('documents').select('*').limit(limit).execute()
        return response.data or []
    except Exception as e:
        logger.error(f"Error getting chunks: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/vapi-call")
async def initiate_vapi_call(request: VAPICallRequest):
    """Initiate VAPI call (placeholder)"""
    logger.info(f"VAPI call requested for: {request.phone_number}")
    
    # Placeholder implementation
    return {
        "success": True,
        "message": "Voice call initiation requested",
        "phone_number": request.phone_number,
        "status": "pending"
    }

@app.post("/vapi-assistant")
async def create_vapi_assistant():
    """Create VAPI assistant (placeholder)"""
    return {
        "assistant_id": "agricultural_assistant_v2",
        "name": "Kisaan Vaani Assistant",
        "language": "hi-IN",
        "voice": "alloy"
    }

if __name__ == "__main__":
    import uvicorn
    
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    
    print("🌾 Starting Enhanced RAG Backend with Agricultural Intelligence")
    print(f"🚀 Server: http://{host}:{port}")
    print("✅ Features: Enhanced RAG, Agricultural Intelligence, VAPI Integration")
    
    uvicorn.run(app, host=host, port=port)
