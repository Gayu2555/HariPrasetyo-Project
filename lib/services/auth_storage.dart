// ==================== FLUTTER AUTH STORAGE ====================

// lib/services/auth_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // <-- Diperlukan untuk http

class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // Save token
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('✅ Token saved successfully');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
  }

  // Save refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
      print('✅ Refresh token saved successfully');
    } catch (e) {
      print('❌ Error saving refresh token: $e');
    }
  }

  // Save user data
  static Future<void> saveUser(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user));
      print('✅ User data saved successfully: ${user['email']}');
    } catch (e) {
      print('❌ Error saving user: $e');
    }
  }

  // Get token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      print('❌ Error getting refresh token: $e');
      return null;
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);
      if (userString != null) {
        return jsonDecode(userString);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all auth data
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userKey);
      print('✅ All auth data cleared');
    } catch (e) {
      print('❌ Error clearing auth data: $e');
    }
  }

  // Logout: Hanya bersihkan data lokal (tambahkan ini!)
  static Future<void> logout() async {
    await clearAll();
  }
}

class ApiService {
  static const String baseUrl =
      'https://api.gayuyunma.my.id'; // ← Hapus spasi trailing!

  /// Safely extract string from various data types
  static String _extractString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }
    return value.toString();
  }

  /// Extract message from response (handles both String and List<String>)
  static String _extractMessage(dynamic data, String defaultMessage) {
    if (data == null) return defaultMessage;

    if (data is Map) {
      if (data['message'] != null) {
        return _extractString(data['message'], defaultMessage);
      }
      if (data['error'] != null) {
        return _extractString(data['error'], defaultMessage);
      }
      if (data['data'] is Map && data['data']['message'] != null) {
        return _extractString(data['data']['message'], defaultMessage);
      }
    }

    return defaultMessage;
  }

  /// Safely convert to int
  static int _toInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  /// Safely convert to bool
  static bool _toBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return defaultValue;
  }

  /// Normalize user data from response
  static Map<String, dynamic> _normalizeUserData(dynamic data) {
    if (data == null) {
      return _getDefaultUserData();
    }

    Map<String, dynamic> userData;

    if (data is Map) {
      if (data['user'] is Map) {
        userData = Map<String, dynamic>.from(data['user']);
      } else {
        userData = Map<String, dynamic>.from(data);
      }
    } else {
      return _getDefaultUserData();
    }

    return {
      'id': _toInt(userData['id']),
      'uuid': _extractString(userData['uuid']),
      'name': _extractString(userData['name']),
      'email': _extractString(userData['email']),
      'phone': userData['phone'],
      'avatar': userData['avatar'],
      'notificationsEnabled': _toBool(userData['notificationsEnabled'], true),
      'darkModeEnabled': _toBool(userData['darkModeEnabled'], false),
      'autoPlayVideos': _toBool(userData['autoPlayVideos'], true),
      'language': _extractString(userData['language'], 'id'),
      'createdAt': userData['createdAt'],
      'updatedAt': userData['updatedAt'],
    };
  }

  /// Get default user data structure
  static Map<String, dynamic> _getDefaultUserData() {
    return {
      'id': 0,
      'uuid': '',
      'name': '',
      'email': '',
      'phone': null,
      'avatar': null,
      'notificationsEnabled': true,
      'darkModeEnabled': false,
      'autoPlayVideos': true,
      'language': 'id',
      'createdAt': null,
      'updatedAt': null,
    };
  }

  /// Process API response
  static Map<String, dynamic> _processResponse({
    required http.Response response,
    required String successMessage,
    required String errorMessage,
  }) {
    try {
      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': _extractMessage(data, successMessage),
          'data': {
            'accessToken': _extractString(data['accessToken']),
            'refreshToken': _extractString(data['refreshToken']),
            'user': _normalizeUserData(data),
          },
        };
      } else {
        return {
          'success': false,
          'message': _extractMessage(data, errorMessage),
        };
      }
    } catch (e, stackTrace) {
      print('❌ Parse Error: $e');
      print('📍 Stack: $stackTrace');
      return {
        'success': false,
        'message': 'Kesalahan memproses data: $e',
      };
    }
  }

  // ==================== REGISTER ====================
  static Future<Map<String, dynamic>> register({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      print('📤 Registering user: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
          'password': password,
        }),
      );

      return _processResponse(
        response: response,
        successMessage: 'Registrasi berhasil',
        errorMessage: 'Registrasi gagal',
      );
    } catch (e, stackTrace) {
      print('❌ Register Error: $e');
      print('📍 Stack: $stackTrace');
      return {
        'success': false,
        'message': 'Koneksi gagal: $e',
      };
    }
  }

  // ==================== LOGIN ====================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('📤 Logging in: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return _processResponse(
        response: response,
        successMessage: 'Login berhasil',
        errorMessage: 'Login gagal',
      );
    } catch (e, stackTrace) {
      print('❌ Login Error: $e');
      print('📍 Stack: $stackTrace');
      return {
        'success': false,
        'message': 'Koneksi gagal: $e',
      };
    }
  }

  // ==================== GOOGLE SIGN IN ====================
  static Future<Map<String, dynamic>> googleSignIn(
      Map<String, dynamic> userData) async {
    try {
      print('📤 Google Sign-In for: ${userData['email']}');

      final requestBody = {
        'email': _extractString(userData['email']),
        'name': _extractString(userData['name']),
        'avatar': _extractString(userData['avatar']),
        'idToken': _extractString(userData['idToken']),
        'accessToken': _extractString(userData['accessToken']),
      };

      if (requestBody['email']!.isEmpty) {
        return {
          'success': false,
          'message': 'Email tidak boleh kosong',
        };
      }

      if (requestBody['idToken']!.isEmpty) {
        return {
          'success': false,
          'message': 'ID Token tidak ditemukan',
        };
      }

      print('📦 Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-signin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      return _processResponse(
        response: response,
        successMessage: 'Login dengan Google berhasil',
        errorMessage: 'Login dengan Google gagal',
      );
    } catch (e, stackTrace) {
      print('❌ Google Sign-In Error: $e');
      print('📍 Stack: $stackTrace');
      return {
        'success': false,
        'message': 'Koneksi gagal: $e',
      };
    }
  }

  // ==================== REFRESH TOKEN ====================
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': {
            'accessToken': _extractString(data['accessToken']),
            'refreshToken': _extractString(data['refreshToken']),
          },
        };
      } else {
        return {
          'success': false,
          'message': _extractMessage(data, 'Refresh token gagal'),
        };
      }
    } catch (e) {
      print('❌ Refresh Token Error: $e');
      return {
        'success': false,
        'message': 'Koneksi gagal: $e',
      };
    }
  }

  // ==================== LOGOUT (API) ====================
  static Future<Map<String, dynamic>> logout({
    required String token,
    String? refreshToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': _extractMessage(data, 'Logout berhasil'),
        };
      } else {
        return {
          'success': false,
          'message': _extractMessage(data, 'Logout gagal'),
        };
      }
    } catch (e) {
      print('❌ Logout Error: $e');
      return {
        'success': false,
        'message': 'Koneksi gagal: $e',
      };
    }
  }
}
