@echo off
echo 🌾 KISAAN VAANI ML API SERVER (SIMPLE) 🌾
echo ==========================================

echo 📦 Installing Python dependencies...
pip install -r requirements_simple.txt

echo 🚀 Starting Flask API server (Simple Mode)...
echo Server will be available at: http://localhost:5000
echo Health check: http://localhost:5000
echo Prediction endpoint: http://localhost:5000/predict

python app_simple.py

pause
