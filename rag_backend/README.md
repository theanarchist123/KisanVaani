# RAG Backend API

A FastAPI-based backend for Retrieval-Augmented Generation (RAG) with Vapi voice assistant integration.

## Features

- 🔍 **Semantic Search**: Vector-based document retrieval using Gemini embeddings
- 🤖 **RAG Pipeline**: Generate contextual answers using Gemini AI
- 🎤 **Vapi Integration**: Voice assistant webhook support
- 📊 **Supabase Integration**: Cloud database for document storage
- 🚀 **FastAPI**: High-performance async API framework

## Setup Instructions

### 1. Install Dependencies

```bash
cd rag_backend
pip install -r requirements.txt
```

### 2. Environment Configuration

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Fill in your API keys in `.env`:
```env
# Gemini AI Configuration
GEMINI_API_KEY=your_actual_gemini_api_key

# Supabase Configuration  
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_anon_key

# Vapi Configuration (optional)
VAPI_API_KEY=your_vapi_api_key

# Server Configuration
HOST=0.0.0.0
PORT=8000
DEBUG=True

# Database Configuration
CHUNKS_TABLE=document_chunks
EMBEDDINGS_DIMENSION=768
```

### 3. Supabase Database Setup

Create a table in your Supabase database:

```sql
-- Create document_chunks table
CREATE TABLE document_chunks (
    id BIGSERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    embedding VECTOR(768),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable vector extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS vector;

-- Create vector search function
CREATE OR REPLACE FUNCTION match_documents(
    query_embedding VECTOR(768),
    match_threshold FLOAT DEFAULT 0.7,
    match_count INT DEFAULT 5
)
RETURNS TABLE(
    id BIGINT,
    content TEXT,
    metadata JSONB,
    similarity FLOAT
)
LANGUAGE SQL STABLE
AS $$
SELECT
    id,
    content,
    metadata,
    1 - (embedding <=> query_embedding) AS similarity
FROM document_chunks
WHERE 1 - (embedding <=> query_embedding) > match_threshold
ORDER BY embedding <=> query_embedding
LIMIT match_count;
$$;

-- Create index for vector search
CREATE INDEX ON document_chunks USING ivfflat (embedding vector_cosine_ops);
```

### 4. Run the Server

```bash
python main.py
```

Or using uvicorn directly:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at:
- **API**: http://localhost:8000
- **Docs**: http://localhost:8000/docs
- **Health**: http://localhost:8000/health

## API Endpoints

### 📊 Health & Info
- `GET /` - API information
- `GET /health` - Health check

### 🔍 Query & Search  
- `POST /query` - RAG query with answer generation
- `POST /search` - Search document chunks
- `GET /chunks` - Get sample chunks

### 🎤 Vapi Integration
- `POST /webhook` - Vapi voice assistant webhook

### 🧪 Testing
- `POST /test-embedding` - Test embedding generation

## Usage Examples

### Query with RAG
```python
import requests

response = requests.post("http://localhost:8000/query", json={
    "question": "What is machine learning?",
    "max_chunks": 5,
    "similarity_threshold": 0.7
})

print(response.json())
```

### Search Chunks
```python
response = requests.post("http://localhost:8000/search", json={
    "query": "artificial intelligence",
    "limit": 10
})

print(response.json())
```

### Vapi Webhook Integration
Configure your Vapi assistant to send webhooks to:
```
POST http://your-domain.com/webhook
```

## Project Structure

```
rag_backend/
├── main.py              # FastAPI application
├── supabase_client.py   # Supabase database client
├── rag_processor.py     # RAG processing with Gemini
├── query.py             # Query coordination
├── requirements.txt     # Python dependencies
├── .env.example        # Environment template
└── README.md           # This file
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `GEMINI_API_KEY` | Google Gemini AI API key | Yes |
| `SUPABASE_URL` | Supabase project URL | Yes |
| `SUPABASE_KEY` | Supabase anon key | Yes |
| `VAPI_API_KEY` | Vapi API key | No |
| `HOST` | Server host | No (default: 0.0.0.0) |
| `PORT` | Server port | No (default: 8000) |
| `DEBUG` | Debug mode | No (default: True) |
| `CHUNKS_TABLE` | Database table name | No (default: document_chunks) |

## Troubleshooting

### Common Issues

1. **Import Errors**: Make sure all dependencies are installed:
   ```bash
   pip install -r requirements.txt
   ```

2. **Supabase Connection**: Verify your Supabase URL and key are correct

3. **Gemini API**: Ensure your Gemini API key is valid and has sufficient quota

4. **Vector Search**: Make sure the `vector` extension is enabled in Supabase

### Logs
Check the console output for detailed error messages and debugging information.

## Production Deployment

For production deployment:

1. Set `DEBUG=False` in environment
2. Configure proper CORS origins
3. Use a production WSGI server
4. Set up proper logging
5. Configure database connection pooling
6. Add authentication/authorization as needed

## License

MIT License - feel free to use this in your projects!
