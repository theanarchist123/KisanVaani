@echo off
echo 🌾 KISAAN VAANI ML API SERVER 🌾
echo ================================

echo 📦 Installing Python dependencies...
pip install -r requirements.txt

echo 🚀 Starting Flask API server...
echo Server will be available at: http://localhost:5000
echo Health check: http://localhost:5000
echo Prediction endpoint: http://localhost:5000/predict
echo Model info: http://localhost:5000/model-info

python app.py

pause
