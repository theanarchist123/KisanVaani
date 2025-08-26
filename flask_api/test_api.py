import requests
import json

def test_flask_api():
    base_url = "http://localhost:5000"
    
    print("🌾 Testing Kisaan Vaani ML API 🌾")
    print("=" * 50)
    
    # Test 1: Health check
    print("1. Testing health check...")
    try:
        response = requests.get(f"{base_url}/")
        if response.status_code == 200:
            print("✅ Health check passed")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Connection error: {e}")
        return
    
    print("\n" + "-" * 50)
    
    # Test 2: Model info
    print("2. Testing model info...")
    try:
        response = requests.get(f"{base_url}/model-info")
        if response.status_code == 200:
            model_info = response.json()
            print("✅ Model info retrieved")
            print(f"   Model: {model_info['model_info']['model_name']}")
            print(f"   R² Score: {model_info['model_info']['performance_metrics']['r2_score']:.4f}")
        else:
            print(f"❌ Model info failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    print("\n" + "-" * 50)
    
    # Test 3: Sample prediction
    print("3. Testing yield prediction...")
    sample_data = {
        "Crop": "Wheat",
        "State": "Punjab",
        "Soil_Type": "Alluvial",
        "Season": "Rabi",
        "Rainfall": 400,
        "Temperature": 22,
        "Land_Size": 2.5,
        "Humidity": 65,
        "pH": 7.0,
        "Nitrogen": 80,
        "Phosphorus": 40,
        "Potassium": 60
    }
    
    try:
        response = requests.post(
            f"{base_url}/predict",
            headers={"Content-Type": "application/json"},
            data=json.dumps(sample_data)
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Prediction successful!")
            print(f"   Predicted Yield: {result['prediction']['predicted_yield']} {result['prediction']['unit']}")
            print(f"   Confidence: {result['prediction']['confidence']:.4f}")
            print(f"   Model Used: {result['model_info']['model_name']}")
        else:
            print(f"❌ Prediction failed: {response.status_code}")
            print(f"   Error: {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    print("\n" + "=" * 50)
    print("🎉 API testing completed!")

if __name__ == "__main__":
    test_flask_api()
