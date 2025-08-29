"""
Supabase client configuration and database operations
"""

import os
from typing import List, Dict, Any, Optional
from supabase import create_client, Client
import logging
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

logger = logging.getLogger(__name__)

class SupabaseClient:
    def __init__(self):
        """Initialize Supabase client with environment variables"""
        self.url = os.getenv("SUPABASE_URL")
        self.key = os.getenv("SUPABASE_KEY")
        self.chunks_table = os.getenv("CHUNKS_TABLE", "document_chunks")
        
        if not self.url or not self.key:
            raise ValueError("SUPABASE_URL and SUPABASE_KEY must be set in environment variables")
        
        self.client: Client = create_client(self.url, self.key)
        logger.info("Supabase client initialized successfully")
    
    async def search_similar_chunks(
        self, 
        query_embedding: List[float], 
        limit: int = 5,
        similarity_threshold: float = 0.7
    ) -> List[Dict[str, Any]]:
        """
        Search for similar document chunks using embedding similarity
        
        Args:
            query_embedding: The embedding vector for the query
            limit: Maximum number of results to return
            similarity_threshold: Minimum similarity score (0-1)
        
        Returns:
            List of similar document chunks with metadata
        """
        try:
            # Use Supabase's vector similarity search
            # This assumes you have a vector column and pgvector extension enabled
            response = self.client.rpc(
                'match_documents',
                {
                    'query_embedding': query_embedding,
                    'match_threshold': similarity_threshold,
                    'match_count': limit
                }
            ).execute()
            
            if response.data:
                logger.info(f"Found {len(response.data)} similar chunks")
                return response.data
            else:
                logger.warning("No similar chunks found")
                return []
                
        except Exception as e:
            logger.error(f"Error searching similar chunks: {str(e)}")
            # Fallback to basic text search if vector search fails
            return await self._fallback_text_search(limit)
    
    async def _fallback_text_search(self, limit: int = 5) -> List[Dict[str, Any]]:
        """Fallback text-based search when vector search is not available"""
        try:
            response = self.client.table(self.chunks_table).select("*").limit(limit).execute()
            return response.data if response.data else []
        except Exception as e:
            logger.error(f"Fallback search failed: {str(e)}")
            return []
    
    async def get_all_chunks(self, limit: int = 100) -> List[Dict[str, Any]]:
        """
        Retrieve all document chunks from the database
        
        Args:
            limit: Maximum number of chunks to retrieve
        
        Returns:
            List of document chunks
        """
        try:
            response = self.client.table(self.chunks_table).select("*").limit(limit).execute()
            
            if response.data:
                logger.info(f"Retrieved {len(response.data)} chunks")
                return response.data
            else:
                logger.warning("No chunks found in database")
                return []
                
        except Exception as e:
            logger.error(f"Error retrieving chunks: {str(e)}")
            return []
    
    async def insert_chunk(
        self, 
        content: str, 
        embedding: List[float], 
        metadata: Optional[Dict[str, Any]] = None
    ) -> bool:
        """
        Insert a new document chunk with embedding
        
        Args:
            content: The text content of the chunk
            embedding: The embedding vector for the content
            metadata: Additional metadata for the chunk
        
        Returns:
            True if insertion was successful, False otherwise
        """
        try:
            chunk_data = {
                "content": content,
                "embedding": embedding,
                "metadata": metadata or {}
            }
            
            response = self.client.table(self.chunks_table).insert(chunk_data).execute()
            
            if response.data:
                logger.info("Chunk inserted successfully")
                return True
            else:
                logger.error("Failed to insert chunk")
                return False
                
        except Exception as e:
            logger.error(f"Error inserting chunk: {str(e)}")
            return False
    
    async def health_check(self) -> bool:
        """
        Check if Supabase connection is healthy
        
        Returns:
            True if connection is healthy, False otherwise
        """
        try:
            # Simple query to test connection
            response = self.client.table(self.chunks_table).select("id").limit(1).execute()
            logger.info("Supabase health check passed")
            return True
        except Exception as e:
            logger.error(f"Supabase health check failed: {str(e)}")
            return False

# Global instance
supabase_client = None

def get_supabase_client() -> SupabaseClient:
    """Get or create global Supabase client instance"""
    global supabase_client
    if supabase_client is None:
        supabase_client = SupabaseClient()
    return supabase_client
