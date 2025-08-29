"""
Enhanced RAG (Retrieval-Augmented Generation) processor with agricultural intelligence
"""

import os
import google.generativeai as genai
from typing import List, Dict, Any, Optional
import logging
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from dotenv import load_dotenv
import json
import re
from datetime import datetime

# Load environment variables
load_dotenv()

logger = logging.getLogger(__name__)

class EnhancedRAGProcessor:
    def __init__(self):
        """Initialize enhanced Gemini AI RAG processor with agricultural intelligence"""
        self.api_key = os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            raise ValueError("GEMINI_API_KEY must be set in environment variables")
        
        # Configure Gemini AI
        genai.configure(api_key=self.api_key)
        
        # Initialize models with better configurations
        self.embedding_model = "models/embedding-001"
        
        # Enhanced generation model with better configuration
        generation_config = {
            "temperature": 0.7,
            "top_p": 0.8,
            "top_k": 40,
            "max_output_tokens": 1024,
        }
        
        self.generation_model = genai.GenerativeModel(
            'gemini-pro',
            generation_config=generation_config
        )
        
        # Agricultural knowledge base
        self.agricultural_context = self._load_agricultural_context()
        
        logger.info("Enhanced RAG Processor initialized with agricultural intelligence")
    
    def _load_agricultural_context(self) -> Dict[str, Any]:
        """Load agricultural context and knowledge base"""
        return {
            "crops": {
                "wheat": {"season": "rabi", "water_need": "medium", "soil": ["alluvial", "black"], "temp_range": "15-25°C"},
                "rice": {"season": "kharif", "water_need": "high", "soil": ["alluvial", "clayey"], "temp_range": "20-35°C"},
                "maize": {"season": "kharif", "water_need": "medium", "soil": ["alluvial", "red"], "temp_range": "18-32°C"},
                "cotton": {"season": "kharif", "water_need": "medium", "soil": ["black", "alluvial"], "temp_range": "20-35°C"},
                "sugarcane": {"season": "year-round", "water_need": "very_high", "soil": ["alluvial", "black"], "temp_range": "20-40°C"}
            },
            "seasons": {
                "rabi": {"months": ["Oct", "Nov", "Dec", "Jan", "Feb", "Mar"], "characteristics": "Winter crop, harvested in spring"},
                "kharif": {"months": ["Jun", "Jul", "Aug", "Sep", "Oct"], "characteristics": "Monsoon crop, depends on rainfall"},
                "zaid": {"months": ["Mar", "Apr", "May", "Jun"], "characteristics": "Summer crop, requires irrigation"}
            },
            "soil_types": {
                "alluvial": {"characteristics": "Fertile, good for most crops", "crops": ["wheat", "rice", "sugarcane"]},
                "black": {"characteristics": "Cotton soil, retains moisture", "crops": ["cotton", "wheat", "jowar"]},
                "red": {"characteristics": "Good drainage, suitable for coarse grains", "crops": ["maize", "groundnut"]},
                "laterite": {"characteristics": "Acidic, needs lime treatment", "crops": ["cashew", "coconut"]},
                "sandy": {"characteristics": "Good drainage, low fertility", "crops": ["bajra", "groundnut"]}
            },
            "weather_factors": {
                "temperature": "Critical for crop growth and development",
                "rainfall": "Essential for crop irrigation and growth",
                "humidity": "Affects disease susceptibility and growth",
                "wind": "Important for pollination and disease spread"
            }
        }
    
    async def generate_embedding(self, text: str) -> List[float]:
        """Generate enhanced embedding with agricultural context awareness"""
        try:
            # Preprocess text to add agricultural context
            enhanced_text = self._enhance_text_with_context(text)
            
            # Generate embedding using Gemini
            result = genai.embed_content(
                model=self.embedding_model,
                content=enhanced_text,
                task_type="retrieval_query"
            )
            
            embedding = result['embedding']
            logger.info(f"Generated enhanced embedding of dimension {len(embedding)}")
            return embedding
            
        except Exception as e:
            logger.error(f"Error generating embedding: {str(e)}")
            # Return a zero vector as fallback
            return [0.0] * 768
    
    def _enhance_text_with_context(self, text: str) -> str:
        """Enhance text with agricultural context"""
        enhanced_text = text.lower()
        
        # Add context for crop mentions
        for crop in self.agricultural_context["crops"]:
            if crop in enhanced_text:
                crop_info = self.agricultural_context["crops"][crop]
                enhanced_text += f" {crop} farming season {crop_info['season']} water requirement {crop_info['water_need']}"
        
        return enhanced_text
    
    async def generate_answer(
        self, 
        question: str, 
        context_chunks: List[Dict[str, Any]],
        user_context: Optional[Dict[str, Any]] = None
    ) -> str:
        """Generate intelligent answer with agricultural expertise"""
        try:
            # Analyze question type and intent
            question_analysis = self._analyze_question(question)
            
            # Prepare enhanced context
            context_text = self._prepare_enhanced_context(context_chunks, question_analysis)
            
            # Create intelligent prompt
            prompt = self._create_intelligent_prompt(question, context_text, question_analysis, user_context)
            
            # Generate response using Gemini
            response = await self._generate_with_gemini(prompt)
            
            # Post-process response for better quality
            enhanced_response = self._enhance_response(response, question_analysis)
            
            logger.info("Successfully generated intelligent answer using enhanced RAG")
            return enhanced_response
            
        except Exception as e:
            logger.error(f"Error generating answer: {str(e)}")
            return self._generate_fallback_response(question)
    
    def _analyze_question(self, question: str) -> Dict[str, Any]:
        """Analyze question to understand intent and context"""
        question_lower = question.lower()
        
        analysis = {
            "type": "general",
            "crop_mentioned": [],
            "season_mentioned": [],
            "topic": "general",
            "urgency": "normal",
            "requires_specific_data": False
        }
        
        # Detect crop mentions
        for crop in self.agricultural_context["crops"]:
            if crop in question_lower:
                analysis["crop_mentioned"].append(crop)
        
        # Detect season mentions
        for season in self.agricultural_context["seasons"]:
            if season in question_lower:
                analysis["season_mentioned"].append(season)
        
        # Detect topic categories
        if any(word in question_lower for word in ["disease", "pest", "infection", "fungus", "insect"]):
            analysis["topic"] = "disease_pest"
        elif any(word in question_lower for word in ["fertilizer", "nutrition", "nutrient", "manure"]):
            analysis["topic"] = "nutrition"
        elif any(word in question_lower for word in ["irrigation", "water", "rainfall", "drought"]):
            analysis["topic"] = "water_management"
        elif any(word in question_lower for word in ["yield", "production", "harvest", "income"]):
            analysis["topic"] = "yield_economics"
        elif any(word in question_lower for word in ["weather", "climate", "temperature", "humidity"]):
            analysis["topic"] = "weather"
        elif any(word in question_lower for word in ["soil", "land", "fertility", "ph"]):
            analysis["topic"] = "soil_management"
        elif any(word in question_lower for word in ["seed", "variety", "planting", "sowing"]):
            analysis["topic"] = "seed_planting"
        
        # Detect urgency
        if any(word in question_lower for word in ["urgent", "emergency", "immediate", "critical", "dying"]):
            analysis["urgency"] = "high"
        elif any(word in question_lower for word in ["when", "how", "why", "what"]):
            analysis["urgency"] = "normal"
        
        # Detect if specific data is needed
        if any(word in question_lower for word in ["price", "cost", "rate", "market", "sell"]):
            analysis["requires_specific_data"] = True
        
        return analysis
    
    def _prepare_enhanced_context(self, chunks: List[Dict[str, Any]], question_analysis: Dict[str, Any]) -> str:
        """Prepare enhanced context based on question analysis"""
        if not chunks:
            return "No specific context found in documents."
        
        context_parts = []
        
        # Add relevant agricultural knowledge first
        if question_analysis["crop_mentioned"]:
            for crop in question_analysis["crop_mentioned"]:
                if crop in self.agricultural_context["crops"]:
                    crop_info = self.agricultural_context["crops"][crop]
                    context_parts.append(f"Agricultural Knowledge - {crop.title()}: Season: {crop_info['season']}, Water need: {crop_info['water_need']}, Suitable soil: {', '.join(crop_info['soil'])}, Temperature: {crop_info['temp_range']}")
        
        # Add document context
        for i, chunk in enumerate(chunks[:5], 1):
            content = chunk.get('content', '').strip()
            if content:
                similarity = chunk.get('similarity', 0.0)
                context_parts.append(f"Document {i} (Relevance: {similarity:.2f}): {content}")
        
        # Add topic-specific guidance
        topic = question_analysis["topic"]
        if topic in ["disease_pest", "nutrition", "water_management", "soil_management"]:
            context_parts.append(f"Expert Guidance: For {topic.replace('_', ' ')} questions, provide specific, actionable advice with preventive measures and treatment options.")
        
        return "\n\n".join(context_parts)
    
    def _create_intelligent_prompt(
        self, 
        question: str, 
        context: str, 
        question_analysis: Dict[str, Any],
        user_context: Optional[Dict[str, Any]] = None
    ) -> str:
        """Create an intelligent, context-aware prompt"""
        
        base_persona = """You are KisaanVaani AI, an expert agricultural consultant with deep knowledge of Indian farming practices. You have expertise in:
- Crop management and cultivation techniques
- Pest and disease identification and treatment
- Soil health and fertilizer recommendations
- Weather-based farming advice
- Market trends and pricing (when available)
- Sustainable and organic farming practices
- Government schemes and subsidies for farmers"""

        # Customize persona based on question type
        if question_analysis["topic"] == "disease_pest":
            persona_addition = "\nYou specialize in plant pathology and integrated pest management. Provide specific treatment recommendations."
        elif question_analysis["topic"] == "nutrition":
            persona_addition = "\nYou have deep expertise in soil nutrition and fertilizer management. Focus on sustainable nutrient management."
        elif question_analysis["topic"] == "yield_economics":
            persona_addition = "\nYou understand agricultural economics and yield optimization. Provide practical advice for income maximization."
        else:
            persona_addition = "\nYou provide comprehensive agricultural guidance with practical, actionable advice."
        
        # Construct the intelligent prompt
        prompt = f"""{base_persona}{persona_addition}

Context Information:
{context}

Farmer's Question: {question}

Response Guidelines:
1. **Accuracy**: Use only information from the provided context and your agricultural expertise
2. **Practicality**: Provide actionable, step-by-step advice that farmers can implement
3. **Local Relevance**: Consider Indian farming conditions, seasons, and practices
4. **Safety**: Always prioritize farmer safety and sustainable practices
5. **Clarity**: Use simple, clear language that farmers can easily understand
6. **Completeness**: Address the question thoroughly while being concise

{self._get_topic_specific_instructions(question_analysis)}

Provide your expert response:"""

        return prompt
    
    def _get_topic_specific_instructions(self, question_analysis: Dict[str, Any]) -> str:
        """Get topic-specific instructions for the prompt"""
        topic = question_analysis["topic"]
        
        instructions = {
            "disease_pest": """
- Identify the problem clearly
- Provide both organic and chemical treatment options
- Include preventive measures
- Mention when to consult local agricultural extension officer""",
            
            "nutrition": """
- Recommend appropriate fertilizers (organic and chemical)
- Suggest soil testing if needed
- Provide application timing and quantities
- Consider crop stage and season""",
            
            "water_management": """
- Consider local water availability
- Suggest efficient irrigation methods
- Provide drought/flood management advice
- Include water conservation techniques""",
            
            "yield_economics": """
- Focus on cost-effective solutions
- Suggest yield improvement techniques
- Mention market timing when relevant
- Consider ROI for recommendations""",
            
            "weather": """
- Provide weather-based farming advice
- Suggest protective measures
- Include crop scheduling recommendations
- Consider seasonal variations""",
            
            "soil_management": """
- Recommend soil health improvement practices
- Suggest appropriate soil amendments
- Include organic matter management
- Consider long-term soil sustainability"""
        }
        
        return instructions.get(topic, "- Provide comprehensive, practical agricultural advice")
    
    async def _generate_with_gemini(self, prompt: str) -> str:
        """Generate response using enhanced Gemini model"""
        try:
            response = self.generation_model.generate_content(prompt)
            return response.text
        except Exception as e:
            logger.error(f"Error with Gemini generation: {str(e)}")
            return "I apologize, but I'm experiencing technical difficulties. Please try again or consult your local agricultural extension officer."
    
    def _enhance_response(self, response: str, question_analysis: Dict[str, Any]) -> str:
        """Post-process response for better quality"""
        # Add urgency indicators if needed
        if question_analysis["urgency"] == "high":
            if not any(word in response.lower() for word in ["immediate", "urgent", "quickly"]):
                response = "⚠️ **Urgent Action Required** - " + response
        
        # Add helpful formatting
        response = self._format_response(response)
        
        # Add relevant disclaimers
        if question_analysis["requires_specific_data"]:
            response += "\n\n💡 **Note**: For current market prices and rates, please check with your local agricultural market committee (APMC) or use government price tracking apps."
        
        return response
    
    def _format_response(self, response: str) -> str:
        """Format response for better readability"""
        # Add bullet points for lists
        lines = response.split('\n')
        formatted_lines = []
        
        for line in lines:
            line = line.strip()
            if line and not line.startswith('•') and not line.startswith('-'):
                # Check if this looks like a list item
                if re.match(r'^\d+\.', line) or line.lower().startswith(('first', 'second', 'third', 'next', 'then', 'finally')):
                    line = "• " + line
            formatted_lines.append(line)
        
        return '\n'.join(formatted_lines)
    
    def _generate_fallback_response(self, question: str) -> str:
        """Generate fallback response when main processing fails"""
        fallback_responses = {
            "disease": "For plant disease issues, I recommend: 1) Remove affected parts immediately, 2) Improve air circulation, 3) Apply appropriate fungicide, 4) Consult your local agricultural extension officer for specific treatment.",
            "pest": "For pest problems: 1) Identify the pest correctly, 2) Use integrated pest management, 3) Consider both organic and chemical options, 4) Monitor regularly for effectiveness.",
            "fertilizer": "For fertilizer recommendations: 1) Conduct soil testing first, 2) Apply based on crop requirements, 3) Consider organic alternatives, 4) Follow proper timing and quantities.",
            "water": "For water management: 1) Use efficient irrigation methods, 2) Consider drip or sprinkler systems, 3) Mulch to conserve moisture, 4) Plan based on weather forecasts.",
            "default": "I apologize for the technical difficulty. For immediate help, please contact your local agricultural extension officer or visit the nearest Krishi Vigyan Kendra (KVK)."
        }
        
        question_lower = question.lower()
        for key in fallback_responses:
            if key in question_lower:
                return fallback_responses[key]
        
        return fallback_responses["default"]

# Global instance
enhanced_rag_processor = None

def get_enhanced_rag_processor() -> EnhancedRAGProcessor:
    """Get or create global enhanced RAG processor instance"""
    global enhanced_rag_processor
    if enhanced_rag_processor is None:
        enhanced_rag_processor = EnhancedRAGProcessor()
    return enhanced_rag_processor
