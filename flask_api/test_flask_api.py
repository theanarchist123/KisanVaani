#!/usr/bin/env python3
"""
Test Flask API endpoints
"""
import requests
import json

def test_flask_api():
    print("=== FLASK API TEST ===\n")
    
    base_url = "http://localhost:5000"
    
    # Test 1: Health check
    print("1. Testing health endpoint...")
    try:
        response = requests.get(f"{base_url}/", timeout=5)
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"   Status: {data.get('status')}")
            print(f"   Message: {data.get('message')}")
            model_info = data.get('model_info', {})
            print(f"   Model: {model_info.get('model_name')}")
    except Exception as e:
        print(f"   ERROR: {e}")
        return False
    
    # Test 2: Prediction endpoint
    print("\n2. Testing prediction endpoint...")
    test_data = {
        "Rainfall": 800,
        "Temperature": 25,
        "Humidity": 70,
        "pH": 6.5,
        "Nitrogen": 40,
        "Phosphorus": 30,
        "Potassium": 20,
        "Crop": "Rice"
    }
    
    try:
        response = requests.post(f"{base_url}/predict", 
                               json=test_data, 
                               timeout=10)
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"   Success: {result.get('success')}")
            print(f"   Predicted Yield: {result.get('predicted_yield')} tons/hectare")
            input_data = result.get('input_data', {})
            print(f"   Input Crop: {input_data.get('Crop')}")
        else:
            print(f"   Error response: {response.text}")
    except Exception as e:
        print(f"   ERROR: {e}")
    
    print("\n=== FLASK API TEST COMPLETE ===")

if __name__ == "__main__":
    test_flask_api()
