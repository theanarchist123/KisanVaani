"""
RAG (Retrieval-Augmented Generation) processor using Gemini AI
"""

import os
import google.generativeai as genai
from typing import List, Dict, Any, Optional
import logging
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

logger = logging.getLogger(__name__)

class RAGProcessor:
    def __init__(self):
        """Initialize Gemini AI and configure the RAG processor"""
        self.api_key = os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            raise ValueError("GEMINI_API_KEY must be set in environment variables")
        
        # Configure Gemini AI
        genai.configure(api_key=self.api_key)
        
        # Initialize models
        self.embedding_model = "models/embedding-001"
        self.generation_model = genai.GenerativeModel('gemini-pro')
        
        logger.info("RAG Processor initialized with Gemini AI")
    
    async def generate_embedding(self, text: str) -> List[float]:
        """
        Generate embedding for given text using Gemini embedding model
        
        Args:
            text: Input text to embed
        
        Returns:
            Embedding vector as list of floats
        """
        try:
            # Generate embedding using Gemini
            result = genai.embed_content(
                model=self.embedding_model,
                content=text,
                task_type="retrieval_query"
            )
            
            embedding = result['embedding']
            logger.info(f"Generated embedding of dimension {len(embedding)}")
            return embedding
            
        except Exception as e:
            logger.error(f"Error generating embedding: {str(e)}")
            # Return a zero vector as fallback
            return [0.0] * 768
    
    async def generate_answer(
        self, 
        question: str, 
        context_chunks: List[Dict[str, Any]]
    ) -> str:
        """
        Generate an answer using Gemini based on question and retrieved context
        
        Args:
            question: User's question
            context_chunks: Retrieved document chunks for context
        
        Returns:
            Generated answer string
        """
        try:
            # Prepare context from chunks
            context_text = self._prepare_context(context_chunks)
            
            # Create prompt for Gemini
            prompt = self._create_rag_prompt(question, context_text)
            
            # Generate response using Gemini
            response = await self._generate_with_gemini(prompt)
            
            logger.info("Successfully generated answer using RAG")
            return response
            
        except Exception as e:
            logger.error(f"Error generating answer: {str(e)}")
            return f"I apologize, but I encountered an error while processing your question: {str(e)}"
    
    def _prepare_context(self, chunks: List[Dict[str, Any]]) -> str:
        """
        Prepare context text from retrieved chunks
        
        Args:
            chunks: List of document chunks
        
        Returns:
            Formatted context string
        """
        if not chunks:
            return "No relevant context found."
        
        context_parts = []
        for i, chunk in enumerate(chunks[:5], 1):  # Limit to top 5 chunks
            content = chunk.get('content', '')
            if content:
                context_parts.append(f"Context {i}: {content}")
        
        return "\n\n".join(context_parts)
    
    def _create_rag_prompt(self, question: str, context: str) -> str:
        """
        Create a well-structured prompt for RAG
        
        Args:
            question: User's question
            context: Retrieved context
        
        Returns:
            Formatted prompt string
        """
        prompt = f"""You are a helpful AI assistant. Please answer the following question based on the provided context. 

Context Information:
{context}

Question: {question}

Instructions:
- Use only the information provided in the context to answer the question
- If the context doesn't contain enough information to answer the question, say so clearly
- Provide a clear, concise, and helpful answer
- If relevant, mention specific details from the context
- Be accurate and avoid making assumptions beyond what's provided

Answer:"""
        
        return prompt
    
    async def _generate_with_gemini(self, prompt: str) -> str:
        """
        Generate response using Gemini model
        
        Args:
            prompt: Input prompt
        
        Returns:
            Generated response
        """
        try:
            response = self.generation_model.generate_content(prompt)
            return response.text
        except Exception as e:
            logger.error(f"Error with Gemini generation: {str(e)}")
            return "I apologize, but I'm unable to generate a response at the moment."
    
    def calculate_similarity(
        self, 
        query_embedding: List[float], 
        chunk_embeddings: List[List[float]]
    ) -> List[float]:
        """
        Calculate cosine similarity between query and chunk embeddings
        
        Args:
            query_embedding: Query embedding vector
            chunk_embeddings: List of chunk embedding vectors
        
        Returns:
            List of similarity scores
        """
        try:
            if not chunk_embeddings:
                return []
            
            query_array = np.array(query_embedding).reshape(1, -1)
            chunk_arrays = np.array(chunk_embeddings)
            
            similarities = cosine_similarity(query_array, chunk_arrays)[0]
            return similarities.tolist()
            
        except Exception as e:
            logger.error(f"Error calculating similarity: {str(e)}")
            return [0.0] * len(chunk_embeddings)
    
    async def process_rag_query(
        self, 
        question: str, 
        retrieved_chunks: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """
        Complete RAG processing pipeline
        
        Args:
            question: User's question
            retrieved_chunks: Retrieved document chunks
        
        Returns:
            Dictionary containing answer and metadata
        """
        try:
            # Generate answer using RAG
            answer = await self.generate_answer(question, retrieved_chunks)
            
            # Prepare response with metadata
            response = {
                "answer": answer,
                "question": question,
                "chunks_used": len(retrieved_chunks),
                "chunks": [
                    {
                        "content": chunk.get('content', ''),
                        "metadata": chunk.get('metadata', {}),
                        "similarity": chunk.get('similarity', 0.0)
                    }
                    for chunk in retrieved_chunks[:3]  # Return top 3 chunks
                ]
            }
            
            logger.info("RAG query processed successfully")
            return response
            
        except Exception as e:
            logger.error(f"Error processing RAG query: {str(e)}")
            return {
                "answer": "I apologize, but I encountered an error processing your question.",
                "question": question,
                "chunks_used": 0,
                "chunks": [],
                "error": str(e)
            }

# Global instance
rag_processor = None

def get_rag_processor() -> RAGProcessor:
    """Get or create global RAG processor instance"""
    global rag_processor
    if rag_processor is None:
        rag_processor = RAGProcessor()
    return rag_processor
