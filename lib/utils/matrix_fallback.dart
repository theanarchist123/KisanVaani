// Temporary fix for missing Matrix4 and Vector classes
// Add this file to lib/utils/

import 'dart:typed_data';

// Matrix4 fallback implementation
class Matrix4 {
  late Float64List _m4storage;

  Matrix4.zero() {
    _m4storage = Float64List(16);
  }

  Matrix4.identity() {
    _m4storage = Float64List(16);
    _m4storage[0] = 1.0;
    _m4storage[5] = 1.0;
    _m4storage[10] = 1.0;
    _m4storage[15] = 1.0;
  }

  Matrix4.copy(Matrix4 other) {
    _m4storage = Float64List.fromList(other._m4storage);
  }

  static Matrix4? tryInvert(Matrix4 matrix) {
    try {
      final result = Matrix4.copy(matrix);
      result.invert();
      return result;
    } catch (e) {
      return null;
    }
  }

  void invert() {
    // Simple identity for now
    _m4storage = Float64List(16);
    _m4storage[0] = 1.0;
    _m4storage[5] = 1.0;
    _m4storage[10] = 1.0;
    _m4storage[15] = 1.0;
  }

  Float64List get storage => _m4storage;
}

// Vector3 fallback
class Vector3 {
  double x, y, z;
  
  Vector3(this.x, this.y, this.z);
}

// Vector4 fallback
class Vector4 {
  double x, y, z, w;
  
  Vector4(this.x, this.y, this.z, this.w);
}
