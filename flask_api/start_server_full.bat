@echo off
echo 🌾 KISAAN VAANI ML API SERVER (FULL) 🌾
echo ======================================

echo 📦 Installing Python dependencies...
echo NOTE: This requires Microsoft Visual C++ 14.0 or greater
echo Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/
pip install -r requirements.txt

echo 🚀 Starting Flask API server (Full ML Mode)...
echo Server will be available at: http://localhost:5000
echo Health check: http://localhost:5000
echo Prediction endpoint: http://localhost:5000/predict
echo Model info: http://localhost:5000/model-info

python app.py

pause
