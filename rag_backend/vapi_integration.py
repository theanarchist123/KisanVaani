"""
VAPI (Voice AI Platform Integration) for KisaanVaani
Advanced voice interaction with agricultural intelligence
"""

import os
import asyncio
import json
import logging
from typing import Dict, Any, Optional, List
from datetime import datetime
from fastapi import HTTPException
import httpx
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

logger = logging.getLogger(__name__)

class VAPIIntegration:
    def __init__(self):
        """Initialize VAPI integration"""
        self.vapi_api_key = os.getenv("VAPI_API_KEY")
        self.vapi_phone_number_id = os.getenv("VAPI_PHONE_NUMBER_ID") 
        self.vapi_assistant_id = os.getenv("VAPI_ASSISTANT_ID")
        self.base_url = "https://api.vapi.ai"
        
        if not self.vapi_api_key:
            logger.warning("VAPI_API_KEY not found - VAPI features will be limited")
        
        self.headers = {
            "Authorization": f"Bearer {self.vapi_api_key}",
            "Content-Type": "application/json"
        }
        
        # Agricultural voice interaction settings
        self.voice_settings = self._get_agricultural_voice_settings()
        
        logger.info("VAPI Integration initialized")
    
    def _get_agricultural_voice_settings(self) -> Dict[str, Any]:
        """Get optimized voice settings for agricultural conversations"""
        return {
            "voice": {
                "provider": "11labs",
                "voiceId": "pNInz6obpgDQGcFmaJgB",  # Adam - clear male voice
                "speed": 0.9,
                "pitch": 0.0,
                "emotion": "neutral"
            },
            "model": {
                "provider": "openai",
                "model": "gpt-4",
                "temperature": 0.3,  # Lower temperature for consistent agricultural advice
                "maxTokens": 500,
                "systemMessage": self._get_agricultural_system_message()
            },
            "transcriber": {
                "provider": "deepgram",
                "model": "nova-2",
                "language": "en-IN",  # Indian English
                "smartFormat": True,
                "keywords": self._get_agricultural_keywords()
            }
        }
    
    def _get_agricultural_system_message(self) -> str:
        """Get system message for agricultural voice assistant"""
        return """You are KisaanVaani, a helpful agricultural voice assistant for Indian farmers. 

Guidelines:
- Speak clearly and use simple language that farmers can understand
- Provide practical, actionable agricultural advice
- Always prioritize farmer safety and sustainable practices
- If you don't know something, guide them to local agricultural experts
- Keep responses concise but complete for voice interaction
- Use measurements and quantities that Indian farmers understand (acres, quintals, etc.)
- Consider Indian climate, seasons, and farming practices
- Be empathetic and supportive - farming is challenging work

Remember: You're speaking to farmers who may have limited formal education but deep practical knowledge. Respect their experience while providing helpful guidance."""
    
    def _get_agricultural_keywords(self) -> List[str]:
        """Get agricultural keywords for better transcription"""
        return [
            "wheat", "rice", "paddy", "maize", "cotton", "sugarcane", "potato", "onion", "tomato",
            "kharif", "rabi", "zaid", "monsoon", "irrigation", "fertilizer", "pesticide", "urea",
            "DAP", "potash", "organic", "vermicompost", "drip", "sprinkler", "borewell",
            "disease", "pest", "fungus", "insect", "crop", "harvest", "yield", "acre", "quintal",
            "market", "mandi", "MSP", "subsidy", "loan", "insurance", "weather", "rainfall"
        ]
    
    async def create_agricultural_assistant(self) -> Dict[str, Any]:
        """Create a specialized agricultural assistant in VAPI"""
        try:
            assistant_config = {
                "name": "KisaanVaani Agricultural Assistant",
                "voice": self.voice_settings["voice"],
                "model": self.voice_settings["model"],
                "transcriber": self.voice_settings["transcriber"],
                "firstMessage": "नमस्ते! मैं किसान वाणी हूं। मैं आपकी खेती से जुड़ी समस्याओं में मदद कर सकता हूं। आप मुझसे हिंदी या अंग्रेजी में बात कर सकते हैं।",
                "endCallMessage": "धन्यवाद! अपनी फसलों का ख्याल रखें और जरूरत हो तो फिर से संपर्क करें।",
                "endCallPhrases": ["goodbye", "bye", "end call", "धन्यवाद", "बाय"],
                "backgroundSound": "office",
                "backchannelingEnabled": True,
                "backgroundDenoisingEnabled": True,
                "modelOutputInMessagesEnabled": True,
                "transportConfigurations": [
                    {
                        "provider": "twilio",
                        "timeout": 600,  # 10 minutes timeout
                        "record": True
                    }
                ],
                "serverUrl": f"{os.getenv('RAG_BACKEND_URL', 'http://localhost:8000')}/vapi-webhook",
                "serverUrlSecret": os.getenv("VAPI_WEBHOOK_SECRET", "kisaan_vaani_webhook_2024")
            }
            
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.base_url}/assistant",
                    headers=self.headers,
                    json=assistant_config,
                    timeout=30.0
                )
                
                if response.status_code == 201:
                    assistant_data = response.json()
                    logger.info(f"Agricultural assistant created: {assistant_data.get('id')}")
                    return assistant_data
                else:
                    logger.error(f"Failed to create assistant: {response.status_code} - {response.text}")
                    raise HTTPException(status_code=response.status_code, detail=response.text)
                    
        except Exception as e:
            logger.error(f"Error creating agricultural assistant: {str(e)}")
            raise
    
    async def start_agricultural_call(
        self, 
        phone_number: str, 
        farmer_context: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Start an agricultural consultation call"""
        try:
            # Customize assistant based on farmer context
            custom_message = self._create_personalized_greeting(farmer_context)
            
            call_config = {
                "assistantId": self.vapi_assistant_id,
                "phoneNumberId": self.vapi_phone_number_id,
                "customer": {
                    "number": phone_number
                },
                "assistantOverrides": {
                    "firstMessage": custom_message,
                    "variableValues": farmer_context or {}
                }
            }
            
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.base_url}/call",
                    headers=self.headers,
                    json=call_config,
                    timeout=30.0
                )
                
                if response.status_code == 201:
                    call_data = response.json()
                    logger.info(f"Agricultural call started: {call_data.get('id')}")
                    return call_data
                else:
                    logger.error(f"Failed to start call: {response.status_code} - {response.text}")
                    raise HTTPException(status_code=response.status_code, detail=response.text)
                    
        except Exception as e:
            logger.error(f"Error starting agricultural call: {str(e)}")
            raise
    
    def _create_personalized_greeting(self, farmer_context: Optional[Dict[str, Any]]) -> str:
        """Create personalized greeting based on farmer context"""
        base_greeting = "नमस्ते! मैं किसान वाणी हूं।"
        
        if not farmer_context:
            return f"{base_greeting} मैं आपकी खेती से जुड़ी समस्याओं में मदद कर सकता हूं।"
        
        name = farmer_context.get('name', '')
        location = farmer_context.get('location', '')
        crops = farmer_context.get('crops', [])
        
        personalized_parts = []
        
        if name:
            personalized_parts.append(f"{name} जी")
        
        if location:
            personalized_parts.append(f"{location} से")
        
        if crops:
            crop_names = ', '.join(crops)
            personalized_parts.append(f"आपकी {crop_names} की फसल के बारे में")
        
        if personalized_parts:
            return f"{base_greeting} {' '.join(personalized_parts)} मैं आपकी मदद कर सकता हूं।"
        
        return f"{base_greeting} मैं आपकी खेती से जुड़ी समस्याओं में मदद कर सकता हूं।"
    
    async def process_vapi_webhook(self, webhook_data: Dict[str, Any]) -> Dict[str, Any]:
        """Process incoming VAPI webhook with agricultural intelligence"""
        try:
            message_type = webhook_data.get("message", {}).get("type", "")
            
            if message_type == "function-call":
                return await self._handle_function_call(webhook_data)
            elif message_type == "transcript":
                return await self._handle_transcript(webhook_data)
            elif message_type == "speech":
                return await self._handle_speech_update(webhook_data)
            else:
                logger.info(f"Received VAPI webhook: {message_type}")
                return {"status": "received"}
                
        except Exception as e:
            logger.error(f"Error processing VAPI webhook: {str(e)}")
            return {"error": str(e)}
    
    async def _handle_function_call(self, webhook_data: Dict[str, Any]) -> Dict[str, Any]:
        """Handle function calls from VAPI assistant"""
        function_call = webhook_data.get("message", {}).get("functionCall", {})
        function_name = function_call.get("name", "")
        parameters = function_call.get("parameters", {})
        
        logger.info(f"Function call: {function_name} with parameters: {parameters}")
        
        if function_name == "get_agricultural_advice":
            return await self._get_agricultural_advice(parameters)
        elif function_name == "get_weather_info":
            return await self._get_weather_info(parameters)
        elif function_name == "get_market_prices":
            return await self._get_market_prices(parameters)
        else:
            return {"result": "Function not supported"}
    
    async def _handle_transcript(self, webhook_data: Dict[str, Any]) -> Dict[str, Any]:
        """Handle transcript updates for better context understanding"""
        transcript = webhook_data.get("message", {}).get("transcript", "")
        logger.info(f"Transcript received: {transcript[:100]}...")
        
        # Store for context analysis
        return {"status": "transcript_processed"}
    
    async def _handle_speech_update(self, webhook_data: Dict[str, Any]) -> Dict[str, Any]:
        """Handle speech updates"""
        speech_data = webhook_data.get("message", {})
        logger.info(f"Speech update: {speech_data.get('status', 'unknown')}")
        return {"status": "speech_processed"}
    
    async def _get_agricultural_advice(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Get agricultural advice through RAG system"""
        try:
            question = parameters.get("question", "")
            farmer_location = parameters.get("location", "")
            crops = parameters.get("crops", [])
            
            # Import here to avoid circular imports
            from enhanced_query_processor import get_enhanced_query_processor
            
            query_processor = get_enhanced_query_processor()
            
            # Prepare user context
            user_context = {
                "location": farmer_location,
                "crops": crops,
                "interaction_type": "voice"
            }
            
            # Process query
            response = await query_processor.process_query(
                question=question,
                user_context=user_context,
                max_chunks=3,  # Limit for voice
                similarity_threshold=0.5
            )
            
            # Format for voice
            voice_response = self._format_for_voice(response["answer"])
            
            return {
                "result": voice_response,
                "confidence": response.get("confidence", 0.5),
                "suggestions": response.get("suggestions", [])
            }
            
        except Exception as e:
            logger.error(f"Error getting agricultural advice: {str(e)}")
            return {
                "result": "मुझे खुशी होगी अगर आप अपना सवाल दोबारा पूछें। तकनीकी समस्या के लिए माफ करें।",
                "error": str(e)
            }
    
    def _format_for_voice(self, text_response: str) -> str:
        """Format text response for better voice delivery"""
        # Remove markdown formatting
        voice_text = text_response.replace("**", "").replace("*", "")
        voice_text = voice_text.replace("###", "").replace("##", "")
        
        # Replace bullet points with spoken format
        voice_text = voice_text.replace("•", "पहले,").replace("-", "")
        
        # Add pauses for better speech flow
        voice_text = voice_text.replace(".", "।").replace(":", " - ")
        
        # Limit length for voice (max ~200 words)
        words = voice_text.split()
        if len(words) > 200:
            voice_text = " ".join(words[:200]) + "... और जानकारी के लिए कृपया दोबारा पूछें।"
        
        return voice_text
    
    async def _get_weather_info(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Get weather information (placeholder - integrate with weather API)"""
        location = parameters.get("location", "")
        return {
            "result": f"मौसम की जानकारी के लिए कृपया अपने स्थानीय मौसम विभाग से संपर्क करें या मौसम ऐप का उपयोग करें।"
        }
    
    async def _get_market_prices(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Get market prices (placeholder - integrate with market API)"""
        crop = parameters.get("crop", "")
        location = parameters.get("location", "")
        return {
            "result": f"बाजार भाव की जानकारी के लिए कृपया अपनी स्थानीय मंडी से संपर्क करें या ई-नाम पोर्टल देखें।"
        }
    
    async def get_call_analytics(self, call_id: str) -> Dict[str, Any]:
        """Get analytics for an agricultural call"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.base_url}/call/{call_id}",
                    headers=self.headers,
                    timeout=30.0
                )
                
                if response.status_code == 200:
                    call_data = response.json()
                    
                    # Extract agricultural insights
                    analytics = self._extract_agricultural_insights(call_data)
                    
                    return analytics
                else:
                    logger.error(f"Failed to get call analytics: {response.status_code}")
                    return {}
                    
        except Exception as e:
            logger.error(f"Error getting call analytics: {str(e)}")
            return {"error": str(e)}
    
    def _extract_agricultural_insights(self, call_data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract agricultural insights from call data"""
        transcript = call_data.get("transcript", "")
        duration = call_data.get("duration", 0)
        
        # Basic analytics
        analytics = {
            "call_duration": duration,
            "topics_discussed": self._extract_topics(transcript),
            "crops_mentioned": self._extract_crops(transcript),
            "farmer_sentiment": self._analyze_sentiment(transcript),
            "follow_up_needed": self._check_follow_up_needed(transcript)
        }
        
        return analytics
    
    def _extract_topics(self, transcript: str) -> List[str]:
        """Extract agricultural topics from transcript"""
        topics = []
        transcript_lower = transcript.lower()
        
        topic_keywords = {
            "disease_management": ["disease", "pest", "infection", "fungus"],
            "irrigation": ["water", "irrigation", "drip", "sprinkler"],
            "fertilizer": ["fertilizer", "urea", "dap", "nutrition"],
            "weather": ["weather", "rain", "drought", "climate"],
            "market": ["price", "market", "sell", "mandi"]
        }
        
        for topic, keywords in topic_keywords.items():
            if any(keyword in transcript_lower for keyword in keywords):
                topics.append(topic)
        
        return topics
    
    def _extract_crops(self, transcript: str) -> List[str]:
        """Extract mentioned crops from transcript"""
        crops = []
        transcript_lower = transcript.lower()
        
        crop_names = ["wheat", "rice", "maize", "cotton", "sugarcane", "potato", "onion", "tomato"]
        
        for crop in crop_names:
            if crop in transcript_lower:
                crops.append(crop)
        
        return crops
    
    def _analyze_sentiment(self, transcript: str) -> str:
        """Basic sentiment analysis"""
        positive_words = ["good", "better", "success", "profit", "happy"]
        negative_words = ["problem", "disease", "loss", "drought", "pest"]
        
        transcript_lower = transcript.lower()
        
        positive_count = sum(1 for word in positive_words if word in transcript_lower)
        negative_count = sum(1 for word in negative_words if word in transcript_lower)
        
        if positive_count > negative_count:
            return "positive"
        elif negative_count > positive_count:
            return "negative"
        else:
            return "neutral"
    
    def _check_follow_up_needed(self, transcript: str) -> bool:
        """Check if follow-up is needed"""
        follow_up_indicators = ["will call back", "need more info", "check later", "emergency"]
        transcript_lower = transcript.lower()
        
        return any(indicator in transcript_lower for indicator in follow_up_indicators)

# Global instance
vapi_integration = None

def get_vapi_integration() -> VAPIIntegration:
    """Get or create global VAPI integration instance"""
    global vapi_integration
    if vapi_integration is None:
        vapi_integration = VAPIIntegration()
    return vapi_integration
