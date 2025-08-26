# ================================================================
# CROP YIELD PREDICTION MODEL FOR GOOGLE COLAB
# Copy each section into separate Colab cells for best results
# ================================================================

# ================================================================
# CELL 1: Import Libraries and Setup
# ================================================================

# Install required packages (run this first in Colab)
!pip install scikit-learn pandas numpy matplotlib seaborn joblib

# Import essential libraries for data science and machine learning
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error
import joblib
import warnings
warnings.filterwarnings('ignore')

# Set up plotting style
plt.style.use('default')
sns.set_palette("husl")

print("🌾 SMART FARMING CROP YIELD PREDICTION MODEL 🌾")
print("=" * 60)

# ================================================================
# CELL 2: Load and Explore Dataset
# ================================================================

# Load the dataset (make sure you've uploaded Smart_Farming_Crop_Yield_2024.csv to Colab)
print("📊 Loading the dataset...")
df = pd.read_csv('Smart_Farming_Crop_Yield_2024.csv')

# Display first 10 rows
print("\n📋 First 10 rows of the dataset:")
print(df.head(10))

# Show dataset information
print(f"\n📈 Dataset Shape: {df.shape}")
print(f"📊 Total Records: {df.shape[0]}")
print(f"📊 Total Features: {df.shape[1]}")

# Display all column names
print("\n📝 Column Names:")
for i, col in enumerate(df.columns, 1):
    print(f"{i:2d}. {col}")

# ================================================================
# CELL 3: Data Analysis and Missing Values Check
# ================================================================

# Check for missing values
print("\n🔍 Missing Values Analysis:")
missing_values = df.isnull().sum()
print(missing_values)

if missing_values.sum() == 0:
    print("✅ Great! No missing values found.")
else:
    print("⚠️  Missing values detected. Consider handling them.")

# Display basic statistics
print("\n📊 Dataset Statistics:")
print(df.describe())

# Check data types
print("\n🔢 Data Types:")
print(df.dtypes)

# Check unique values in categorical columns
categorical_columns = df.select_dtypes(include=['object']).columns.tolist()
print(f"\n📝 Categorical columns: {categorical_columns}")
for col in categorical_columns:
    print(f"\n{col}: {df[col].nunique()} unique values")
    print(f"Sample values: {df[col].unique()[:10]}")

# ================================================================
# CELL 4: Data Preprocessing and Feature Engineering
# ================================================================

print("\n🔄 ENCODING CATEGORICAL VARIABLES")
print("=" * 60)

# Create a copy of the dataframe for processing
df_processed = df.copy()

# Handle missing values if any
df_processed = df_processed.dropna()  # Simple approach - remove rows with missing values

# Initialize label encoders dictionary
label_encoders = {}

# Encode categorical variables using LabelEncoder
for col in categorical_columns:
    # Skip target variable if it's categorical
    if col.lower() not in ['yield', 'production', 'output', 'crop_yield']:
        le = LabelEncoder()
        df_processed[col + '_encoded'] = le.fit_transform(df_processed[col])
        label_encoders[col] = le
        
        print(f"✅ Encoded '{col}': {len(le.classes_)} unique values")
        print(f"   Sample mapping: {dict(zip(le.classes_[:3], le.transform(le.classes_[:3])))}")

print(f"\n📦 Created {len(label_encoders)} label encoders")

# ================================================================
# CELL 5: Feature Selection and Target Variable
# ================================================================

# Automatically detect feature columns
numerical_features = []
encoded_features = []

# Get numerical columns
numerical_cols = df_processed.select_dtypes(include=[np.number]).columns.tolist()

# Common feature names to look for
common_features = ['rainfall', 'temperature', 'humidity', 'ph', 'nitrogen', 
                  'phosphorus', 'potassium', 'land_size', 'area', 'acres']

# Select numerical features
for col in numerical_cols:
    if any(feature in col.lower() for feature in common_features):
        numerical_features.append(col)

# Select encoded categorical features
for col in df_processed.columns:
    if col.endswith('_encoded'):
        encoded_features.append(col)

# Combine all features
feature_columns = numerical_features + encoded_features

# Detect target variable
target_column = None
possible_targets = ['yield', 'crop_yield', 'production', 'output', 'Yield', 'Production']

for target in possible_targets:
    if target in df_processed.columns:
        target_column = target
        break

# If no standard target found, let user specify or use the last numerical column
if target_column is None:
    remaining_numerical = [col for col in numerical_cols if col not in feature_columns]
    if remaining_numerical:
        target_column = remaining_numerical[0]
    else:
        target_column = numerical_cols[-1]  # Use last numerical column

print(f"🎯 Target variable: {target_column}")
print(f"📊 Selected features ({len(feature_columns)}):")
for i, feature in enumerate(feature_columns, 1):
    print(f"   {i:2d}. {feature}")

# ================================================================
# CELL 6: Prepare Data for Machine Learning
# ================================================================

# Prepare features (X) and target (y)
X = df_processed[feature_columns].copy()
y = df_processed[target_column].copy()

print(f"📊 Features shape: {X.shape}")
print(f"🎯 Target shape: {y.shape}")

# Check for any remaining missing values
print(f"\n🔍 Missing values in features: {X.isnull().sum().sum()}")
print(f"🔍 Missing values in target: {y.isnull().sum()}")

# Remove any remaining missing values
if X.isnull().sum().sum() > 0 or y.isnull().sum() > 0:
    mask = ~(X.isnull().any(axis=1) | y.isnull())
    X = X[mask]
    y = y[mask]
    print(f"🧹 Cleaned data shape: X{X.shape}, y{y.shape}")

# Split the dataset (80% training, 20% testing)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, shuffle=True
)

print(f"\n🏋️ Training set: {X_train.shape[0]} samples")
print(f"🧪 Testing set: {X_test.shape[0]} samples")

# ================================================================
# CELL 7: Train Linear Regression Model
# ================================================================

print("\n🤖 TRAINING LINEAR REGRESSION MODEL")
print("=" * 60)

# Initialize and train Linear Regression model
lr_model = LinearRegression()
print("🔄 Training Linear Regression...")
lr_model.fit(X_train, y_train)

# Make predictions
lr_train_pred = lr_model.predict(X_train)
lr_test_pred = lr_model.predict(X_test)

# Calculate metrics for Linear Regression
lr_train_r2 = r2_score(y_train, lr_train_pred)
lr_test_r2 = r2_score(y_test, lr_test_pred)
lr_train_mae = mean_absolute_error(y_train, lr_train_pred)
lr_test_mae = mean_absolute_error(y_test, lr_test_pred)
lr_train_rmse = np.sqrt(mean_squared_error(y_train, lr_train_pred))
lr_test_rmse = np.sqrt(mean_squared_error(y_test, lr_test_pred))

print("✅ Linear Regression training completed!")
print(f"📈 Training R² Score: {lr_train_r2:.4f}")
print(f"📈 Testing R² Score:  {lr_test_r2:.4f}")
print(f"📉 Training MAE:      {lr_train_mae:.2f}")
print(f"📉 Testing MAE:       {lr_test_mae:.2f}")
print(f"📉 Training RMSE:     {lr_train_rmse:.2f}")
print(f"📉 Testing RMSE:      {lr_test_rmse:.2f}")

# ================================================================
# CELL 8: Train Random Forest Regressor Model
# ================================================================

print("\n🌲 TRAINING RANDOM FOREST REGRESSOR MODEL")
print("=" * 60)

# Initialize and train Random Forest Regressor
rf_model = RandomForestRegressor(
    n_estimators=100,
    random_state=42,
    max_depth=15,
    min_samples_split=5,
    min_samples_leaf=2,
    n_jobs=-1  # Use all available cores
)

print("🔄 Training Random Forest Regressor...")
rf_model.fit(X_train, y_train)

# Make predictions
rf_train_pred = rf_model.predict(X_train)
rf_test_pred = rf_model.predict(X_test)

# Calculate metrics for Random Forest
rf_train_r2 = r2_score(y_train, rf_train_pred)
rf_test_r2 = r2_score(y_test, rf_test_pred)
rf_train_mae = mean_absolute_error(y_train, rf_train_pred)
rf_test_mae = mean_absolute_error(y_test, rf_test_pred)
rf_train_rmse = np.sqrt(mean_squared_error(y_train, rf_train_pred))
rf_test_rmse = np.sqrt(mean_squared_error(y_test, rf_test_pred))

print("✅ Random Forest Regressor training completed!")
print(f"📈 Training R² Score: {rf_train_r2:.4f}")
print(f"📈 Testing R² Score:  {rf_test_r2:.4f}")
print(f"📉 Training MAE:      {rf_train_mae:.2f}")
print(f"📉 Testing MAE:       {rf_test_mae:.2f}")
print(f"📉 Training RMSE:     {rf_train_rmse:.2f}")
print(f"📉 Testing RMSE:      {rf_test_rmse:.2f}")

# ================================================================
# CELL 9: Model Evaluation and Comparison
# ================================================================

print("\n📊 MODEL EVALUATION AND COMPARISON")
print("=" * 60)

# Display comprehensive results
print("📈 LINEAR REGRESSION RESULTS:")
print(f"   Training R² Score: {lr_train_r2:.4f}")
print(f"   Testing R² Score:  {lr_test_r2:.4f}")
print(f"   Training MAE:      {lr_train_mae:.2f}")
print(f"   Testing MAE:       {lr_test_mae:.2f}")
print(f"   Training RMSE:     {lr_train_rmse:.2f}")
print(f"   Testing RMSE:      {lr_test_rmse:.2f}")

print("\n🌲 RANDOM FOREST RESULTS:")
print(f"   Training R² Score: {rf_train_r2:.4f}")
print(f"   Testing R² Score:  {rf_test_r2:.4f}")
print(f"   Training MAE:      {rf_train_mae:.2f}")
print(f"   Testing MAE:       {rf_test_mae:.2f}")
print(f"   Training RMSE:     {rf_train_rmse:.2f}")
print(f"   Testing RMSE:      {rf_test_rmse:.2f}")

# Determine best model based on test R² score
if rf_test_r2 > lr_test_r2:
    best_model = rf_model
    best_model_name = "Random Forest"
    best_r2 = rf_test_r2
    best_mae = rf_test_mae
    best_rmse = rf_test_rmse
else:
    best_model = lr_model
    best_model_name = "Linear Regression"
    best_r2 = lr_test_r2
    best_mae = lr_test_mae
    best_rmse = lr_test_rmse

print(f"\n🏆 BEST MODEL: {best_model_name}")
print(f"   R² Score: {best_r2:.4f}")
print(f"   MAE: {best_mae:.2f}")
print(f"   RMSE: {best_rmse:.2f}")

# Create comparison visualization
fig, axes = plt.subplots(2, 2, figsize=(15, 12))

# Plot 1: R² Score comparison
models = ['Linear Regression', 'Random Forest']
r2_scores = [lr_test_r2, rf_test_r2]
axes[0,0].bar(models, r2_scores, color=['skyblue', 'lightgreen'])
axes[0,0].set_title('R² Score Comparison')
axes[0,0].set_ylabel('R² Score')
axes[0,0].set_ylim(0, 1)
for i, v in enumerate(r2_scores):
    axes[0,0].text(i, v + 0.01, f'{v:.3f}', ha='center')

# Plot 2: MAE comparison
mae_scores = [lr_test_mae, rf_test_mae]
axes[0,1].bar(models, mae_scores, color=['orange', 'coral'])
axes[0,1].set_title('Mean Absolute Error Comparison')
axes[0,1].set_ylabel('MAE')
for i, v in enumerate(mae_scores):
    axes[0,1].text(i, v + max(mae_scores)*0.01, f'{v:.2f}', ha='center')

# Plot 3: RMSE comparison
rmse_scores = [lr_test_rmse, rf_test_rmse]
axes[1,0].bar(models, rmse_scores, color=['lightcoral', 'gold'])
axes[1,0].set_title('Root Mean Square Error Comparison')
axes[1,0].set_ylabel('RMSE')
for i, v in enumerate(rmse_scores):
    axes[1,0].text(i, v + max(rmse_scores)*0.01, f'{v:.2f}', ha='center')

# Plot 4: Feature importance for Random Forest
if best_model_name == "Random Forest":
    feature_importance = rf_model.feature_importances_
    feature_names = [col.replace('_encoded', '') for col in feature_columns]
    
    # Sort features by importance
    importance_df = pd.DataFrame({
        'feature': feature_names,
        'importance': feature_importance
    }).sort_values('importance', ascending=True)
    
    axes[1,1].barh(importance_df['feature'], importance_df['importance'], color='lightblue')
    axes[1,1].set_title('Feature Importance (Random Forest)')
    axes[1,1].set_xlabel('Importance')
else:
    axes[1,1].text(0.5, 0.5, 'Feature importance\navailable for\nRandom Forest only', 
                   ha='center', va='center', transform=axes[1,1].transAxes, fontsize=12)
    axes[1,1].set_title('Feature Importance')

plt.tight_layout()
plt.show()

# ================================================================
# CELL 10: Test Model with Sample Input
# ================================================================

print("\n🧪 TESTING MODEL WITH SAMPLE INPUT")
print("=" * 60)

# Define sample input - you can modify these values
sample_input = {
    'Crop': 'Wheat',
    'State': 'Punjab',
    'Soil_Type': 'Alluvial',
    'Season': 'Rabi',  # Add if available in your dataset
    'Rainfall': 400,
    'Temperature': 22,
    'Land_Size': 2,
    'Humidity': 65,     # Add typical values if these columns exist
    'pH': 7.0,
    'Nitrogen': 80,
    'Phosphorus': 40,
    'Potassium': 60
}

print("📝 Sample Input:")
for key, value in sample_input.items():
    print(f"   {key}: {value}")

# Create sample input array
sample_array = []
feature_mapping = {}

# Process each feature in the same order as training
for col in feature_columns:
    if col.endswith('_encoded'):
        # This is an encoded categorical feature
        original_col = col.replace('_encoded', '')
        if original_col in sample_input and original_col in label_encoders:
            try:
                # Check if the value exists in the encoder
                if sample_input[original_col] in label_encoders[original_col].classes_:
                    encoded_value = label_encoders[original_col].transform([sample_input[original_col]])[0]
                    sample_array.append(encoded_value)
                    feature_mapping[col] = f"{sample_input[original_col]} -> {encoded_value}"
                else:
                    # Use most common class if value not found
                    encoded_value = 0
                    sample_array.append(encoded_value)
                    feature_mapping[col] = f"DEFAULT -> {encoded_value}"
                    print(f"⚠️  '{sample_input[original_col]}' not found in {original_col} encoder. Using default.")
            except:
                sample_array.append(0)
                feature_mapping[col] = "ERROR -> 0"
        else:
            # Use default value if feature not provided
            sample_array.append(0)
            feature_mapping[col] = "MISSING -> 0"
    else:
        # This is a numerical feature
        feature_name = col
        if feature_name in sample_input:
            sample_array.append(sample_input[feature_name])
            feature_mapping[col] = str(sample_input[feature_name])
        else:
            # Use median value for missing numerical features
            median_val = X[col].median()
            sample_array.append(median_val)
            feature_mapping[col] = f"MEDIAN -> {median_val:.2f}"
            print(f"ℹ️  Using median value {median_val:.2f} for missing feature '{col}'")

print(f"\n🔧 Feature Mapping:")
for feature, mapping in feature_mapping.items():
    print(f"   {feature}: {mapping}")

# Make prediction
sample_array = np.array(sample_array).reshape(1, -1)
predicted_yield = best_model.predict(sample_array)[0]

print(f"\n🎯 PREDICTION RESULT:")
print(f"   Predicted Yield: {predicted_yield:.2f}")
print(f"   Model Used: {best_model_name}")
print(f"   Model Confidence (R²): {best_r2:.4f}")

# ================================================================
# CELL 11: Save the Trained Model
# ================================================================

print("\n💾 SAVING THE TRAINED MODEL")
print("=" * 60)

# Create a comprehensive model package
model_package = {
    'model': best_model,
    'model_name': best_model_name,
    'label_encoders': label_encoders,
    'feature_columns': feature_columns,
    'target_column': target_column,
    'performance_metrics': {
        'r2_score': best_r2,
        'mae': best_mae,
        'rmse': best_rmse
    },
    'training_info': {
        'training_samples': X_train.shape[0],
        'testing_samples': X_test.shape[0],
        'total_features': len(feature_columns),
        'categorical_features': len(label_encoders),
        'numerical_features': len([col for col in feature_columns if not col.endswith('_encoded')])
    },
    'sample_prediction': {
        'input': sample_input,
        'predicted_yield': predicted_yield
    }
}

# Save the model package
model_filename = 'yield_prediction_model.pkl'
joblib.dump(model_package, model_filename)
print(f"✅ Model saved as '{model_filename}'")

# Verify the saved model
try:
    loaded_model = joblib.load(model_filename)
    verification_pred = loaded_model['model'].predict(sample_array)[0]
    print("✅ Model loading verification successful!")
    print(f"   Saved model: {loaded_model['model_name']}")
    print(f"   R² Score: {loaded_model['performance_metrics']['r2_score']:.4f}")
    print(f"   MAE: {loaded_model['performance_metrics']['mae']:.2f}")
    print(f"   Verification prediction: {verification_pred:.2f}")
    
    if abs(verification_pred - predicted_yield) < 0.001:
        print("✅ Prediction verification passed!")
    else:
        print("⚠️  Prediction verification failed!")
        
except Exception as e:
    print(f"❌ Error loading model: {e}")

# Print model summary
print(f"\n📦 MODEL PACKAGE SUMMARY:")
print(f"   Model Type: {model_package['model_name']}")
print(f"   Total Features: {model_package['training_info']['total_features']}")
print(f"   Categorical Features: {model_package['training_info']['categorical_features']}")
print(f"   Numerical Features: {model_package['training_info']['numerical_features']}")
print(f"   Training Samples: {model_package['training_info']['training_samples']}")
print(f"   Performance (R²): {model_package['performance_metrics']['r2_score']:.4f}")

print("\n🎉 CROP YIELD PREDICTION MODEL COMPLETE!")
print("=" * 60)
print("🌾 Your model is ready for integration!")
print(f"📂 Model file: {model_filename}")
print("🚀 Download this file to use in your Flutter/Flask application!")

# ================================================================
# CELL 12: Download Instructions (Final Cell)
# ================================================================

print("\n📋 INTEGRATION INSTRUCTIONS:")
print("=" * 60)
print("1. 📥 Download the 'yield_prediction_model.pkl' file from Colab")
print("2. 📁 Place it in your Flutter project directory")
print("3. 🔧 Use this Python code to load and use the model:")
print("""
# Load the model
import joblib
model_package = joblib.load('yield_prediction_model.pkl')
model = model_package['model']
encoders = model_package['label_encoders']

# Make predictions
# [Your prediction code here]
""")
print("4. 🌐 Create a Flask API endpoint to serve predictions")
print("5. 📱 Connect your Flutter app to the Flask API")
print("\n✨ Happy farming with AI! 🚜🤖")
