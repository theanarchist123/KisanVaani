"""
Query processing and coordination module
"""

from typing import List, Dict, Any
from dotenv import load_dotenv
from supabase_client import get_supabase_client
from rag_processor import get_rag_processor
import logging

# Load environment variables
load_dotenv()

logger = logging.getLogger(__name__)

class QueryProcessor:
    def __init__(self):
        """Initialize query processor with dependencies"""
        self.supabase_client = get_supabase_client()
        self.rag_processor = get_rag_processor()
        logger.info("Query processor initialized")
    
    async def process_query(
        self, 
        question: str, 
        max_chunks: int = 5,
        similarity_threshold: float = 0.7
    ) -> Dict[str, Any]:
        """
        Process a user query through the complete RAG pipeline
        
        Args:
            question: User's question
            max_chunks: Maximum number of chunks to retrieve
            similarity_threshold: Minimum similarity threshold for chunks
        
        Returns:
            Complete response with answer and metadata
        """
        try:
            logger.info(f"Processing query: {question[:100]}...")
            
            # Step 1: Generate embedding for the question
            query_embedding = await self.rag_processor.generate_embedding(question)
            
            # Step 2: Search for similar chunks
            similar_chunks = await self.supabase_client.search_similar_chunks(
                query_embedding=query_embedding,
                limit=max_chunks,
                similarity_threshold=similarity_threshold
            )
            
            # Step 3: Process with RAG to generate answer
            response = await self.rag_processor.process_rag_query(question, similar_chunks)
            
            # Step 4: Add query metadata
            response.update({
                "query_embedding_dimension": len(query_embedding),
                "similarity_threshold": similarity_threshold,
                "max_chunks_requested": max_chunks
            })
            
            logger.info("Query processed successfully")
            return response
            
        except Exception as e:
            logger.error(f"Error processing query: {str(e)}")
            return {
                "answer": "I apologize, but I encountered an error processing your question. Please try again.",
                "question": question,
                "chunks_used": 0,
                "chunks": [],
                "error": str(e)
            }
    
    async def search_chunks(
        self, 
        query: str, 
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        Search for document chunks without generating an answer
        
        Args:
            query: Search query
            limit: Maximum number of results
        
        Returns:
            List of matching document chunks
        """
        try:
            logger.info(f"Searching chunks for: {query[:100]}...")
            
            # Generate embedding for search
            query_embedding = await self.rag_processor.generate_embedding(query)
            
            # Search for similar chunks
            chunks = await self.supabase_client.search_similar_chunks(
                query_embedding=query_embedding,
                limit=limit
            )
            
            logger.info(f"Found {len(chunks)} matching chunks")
            return chunks
            
        except Exception as e:
            logger.error(f"Error searching chunks: {str(e)}")
            return []
    
    async def get_random_chunks(self, limit: int = 5) -> List[Dict[str, Any]]:
        """
        Get random sample of document chunks
        
        Args:
            limit: Number of chunks to retrieve
        
        Returns:
            List of document chunks
        """
        try:
            chunks = await self.supabase_client.get_all_chunks(limit=limit)
            logger.info(f"Retrieved {len(chunks)} random chunks")
            return chunks
        except Exception as e:
            logger.error(f"Error getting random chunks: {str(e)}")
            return []
    
    async def health_check(self) -> Dict[str, Any]:
        """
        Perform health check on all components
        
        Returns:
            Health status of all components
        """
        health_status = {
            "supabase": False,
            "rag_processor": False,
            "overall": False
        }
        
        try:
            # Check Supabase connection
            health_status["supabase"] = await self.supabase_client.health_check()
            
            # Check RAG processor (try generating a simple embedding)
            try:
                test_embedding = await self.rag_processor.generate_embedding("test")
                health_status["rag_processor"] = len(test_embedding) > 0
            except:
                health_status["rag_processor"] = False
            
            # Overall health
            health_status["overall"] = health_status["supabase"] and health_status["rag_processor"]
            
            logger.info(f"Health check completed: {health_status}")
            return health_status
            
        except Exception as e:
            logger.error(f"Error during health check: {str(e)}")
            health_status["error"] = str(e)
            return health_status

# Global instance
query_processor = None

def get_query_processor() -> QueryProcessor:
    """Get or create global query processor instance"""
    global query_processor
    if query_processor is None:
        query_processor = QueryProcessor()
    return query_processor
