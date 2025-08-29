from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import json

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

@app.get("/")
async def root():
    return {"message": "Mock RAG Backend is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "details": {"overall": True}}

@app.post("/query")
async def query_rag(request: Request):
    try:
        data = await request.json()
        question = data.get("question", "No question provided")
        
        # Create a mock response
        return {
            "answer": f"This is a mock answer to: {question}",
            "question": question,
            "chunks_used": 3,
            "chunks": [
                {"id": 1, "content": "Mock content 1", "metadata": {"source": "mock_doc_1.pdf"}},
                {"id": 2, "content": "Mock content 2", "metadata": {"source": "mock_doc_2.pdf"}},
                {"id": 3, "content": "Mock content 3", "metadata": {"source": "mock_doc_3.pdf"}}
            ],
            "query_embedding_dimension": 768,
            "similarity_threshold": 0.7,
            "max_chunks_requested": 5
        }
    except Exception as e:
        return {"error": str(e)}

@app.post("/webhook")
async def vapi_webhook(request: Request):
    try:
        data = await request.json()
        message = data.get("message", {})
        content = message.get("content", "No content provided")
        
        return {
            "message": f"Processed webhook message: {content}"
        }
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    print("Starting mock RAG server on http://localhost:8001")
    uvicorn.run(app, host="0.0.0.0", port=8001)
