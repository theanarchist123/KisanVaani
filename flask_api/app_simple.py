"""
Simple Flask API Server for Crop Yield Prediction Testing
This is a simplified version for testing the integration
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import random

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app communication

@app.route('/', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'success',
        'message': 'Crop Yield Prediction API is running (Test Mode)',
        'model_info': {
            'model_name': 'Random Forest (Simulated)',
            'r2_score': 0.965,
            'mae': 30.57,
            'total_features': 8
        }
    })

@app.route('/predict', methods=['POST'])
def predict_yield():
    """Predict crop yield based on input parameters (Test Mode)"""
    try:
        # Get input data from request
        input_data = request.get_json()
        
        if not input_data:
            return jsonify({
                'success': False,
                'error': 'No input data provided'
            }), 400
        
        print(f"📝 Received prediction request: {input_data}")
        
        # Simulate prediction based on inputs
        base_yield = 50  # Base yield
        
        # Simple yield calculation based on inputs
        if 'Rainfall' in input_data:
            rainfall_factor = min(input_data['Rainfall'] / 500, 1.5)  # Normalize rainfall
            base_yield *= rainfall_factor
        
        if 'Temperature' in input_data:
            temp = input_data['Temperature']
            if 20 <= temp <= 30:  # Optimal temperature range
                temp_factor = 1.2
            else:
                temp_factor = 0.8
            base_yield *= temp_factor
        
        if 'Land_Size' in input_data:
            base_yield *= input_data['Land_Size']
        
        # Add some randomness for realism
        predicted_yield = base_yield * (0.9 + random.random() * 0.2)
        
        print(f"🎯 Prediction result: {predicted_yield:.2f}")
        
        # Prepare response
        response = {
            'success': True,
            'prediction': {
                'predicted_yield': round(float(predicted_yield), 2),
                'unit': 'tons/hectare',
                'confidence': 0.965
            },
            'model_info': {
                'model_name': 'Random Forest (Simulated)',
                'r2_score': 0.965,
                'mae': 30.57
            },
            'input_processed': input_data,
            'note': 'This is a simulated prediction for testing purposes'
        }
        
        return jsonify(response)
        
    except Exception as e:
        print(f"❌ Error in prediction: {str(e)}")
        return jsonify({
            'success': False,
            'error': f'Prediction failed: {str(e)}'
        }), 500

@app.route('/model-info', methods=['GET'])
def get_model_info():
    """Get model information (Test Mode)"""
    try:
        return jsonify({
            'success': True,
            'model_info': {
                'model_name': 'Random Forest (Simulated)',
                'target_column': 'Yield',
                'performance_metrics': {
                    'r2_score': 0.965,
                    'mae': 30.57,
                    'rmse': 166.58
                },
                'training_info': {
                    'training_samples': 1000,
                    'testing_samples': 250,
                    'total_features': 8,
                    'categorical_features': 4,
                    'numerical_features': 4
                },
                'categorical_features': {
                    'Crop': ['Wheat', 'Rice', 'Maize', 'Cotton', 'Sugarcane'],
                    'State': ['Punjab', 'Haryana', 'Uttar Pradesh', 'Rajasthan'],
                    'Soil_Type': ['Alluvial', 'Black', 'Red', 'Laterite'],
                    'Season': ['Rabi', 'Kharif', 'Zaid']
                },
                'numerical_features': ['Rainfall', 'Temperature', 'Land_Size', 'Humidity'],
                'note': 'This is simulated model information for testing'
            }
        })
        
    except Exception as e:
        print(f"Error getting model info: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    print("🌾 KISAAN VAANI ML API SERVER (TEST MODE) 🌾")
    print("=" * 60)
    print("✅ Server starting in test mode...")
    print("📡 Server will be available at: http://localhost:5000")
    print("🔍 Health check: http://localhost:5000")
    print("🎯 Prediction endpoint: http://localhost:5000/predict")
    print("ℹ️  Model info: http://localhost:5000/model-info")
    print("=" * 60)
    
    app.run(host='0.0.0.0', port=5000, debug=True)
