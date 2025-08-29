@echo off
echo 🌾 KISAAN VAANI ENHANCED RAG BACKEND 🌾
echo ========================================
echo Starting Enhanced RAG Backend with Agricultural Intelligence...
echo.

echo 📦 Installing Enhanced Dependencies...
pip install -r requirements.txt

echo.
echo 🔍 Checking Environment Variables...
if not exist .env (
    echo ⚠️  .env file not found. Copying from .env.example...
    copy .env.example .env
    echo ✅ Please update .env file with your API keys before continuing.
    echo.
)

echo 🚀 Starting Enhanced RAG Backend Server...
echo Server will be available at: http://localhost:8000
echo Features: Agricultural Intelligence, VAPI Integration, Context Awareness
echo.
echo Endpoints:
echo - Health: http://localhost:8000/health
echo - Query: http://localhost:8000/query (Enhanced)
echo - VAPI Webhook: http://localhost:8000/vapi-webhook
echo - VAPI Call: http://localhost:8000/vapi-call
echo.

python main.py

pause
