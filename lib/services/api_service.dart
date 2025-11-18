// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.gayuyunma.my.id';

  // ==================== HELPER METHODS ====================

  /// Safely decode JSON response
  static dynamic _safeJsonDecode(String body) {
    try {
      // Remove any BOM or invisible characters
      String cleanBody = body.trim();

      // Check if response is empty
      if (cleanBody.isEmpty) {
        print('⚠️ Empty response body');
        return {'message': 'Empty response from server'};
      }

      // Try to decode
      return jsonDecode(cleanBody);
    } catch (e) {
      print('❌ JSON Decode Error: $e');
      print('📄 Raw body: $body');
      print('📄 Body length: ${body.length}');
      print(
          '📄 First char code: ${body.isNotEmpty ? body.codeUnitAt(0) : 'empty'}');

      // Return error object
      return {
        'message': 'Invalid response format from server',
        'rawError': e.toString(),
      };
    }
  }

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
      // Check for message field
      if (data['message'] != null) {
        return _extractString(data['message'], defaultMessage);
      }
      // Check for error field
      if (data['error'] != null) {
        return _extractString(data['error'], defaultMessage);
      }
      // Check for nested message
      if (data['data'] is Map && data['data']['message'] != null) {
        return _extractString(data['data']['message'], defaultMessage);
      }
      // Check for rawError (from our safe decode)
      if (data['rawError'] != null) {
        return 'Server error: ${data['rawError']}';
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

    // Extract user data from various response structures
    if (data is Map) {
      if (data['user'] is Map) {
        userData = Map<String, dynamic>.from(data['user']);
      } else {
        userData = Map<String, dynamic>.from(data);
      }
    } else {
      return _getDefaultUserData();
    }

    // Normalize all fields with safe type conversion
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

  /// Process API response with enhanced error handling
  static Map<String, dynamic> _processResponse({
    required http.Response response,
    required String successMessage,
    required String errorMessage,
  }) {
    try {
      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print(
          '📥 Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      // Check for HTML error pages (common with reverse proxies)
      if (response.body.trim().startsWith('<')) {
        print('⚠️ Received HTML instead of JSON');
        return {
          'success': false,
          'message':
              'Server returned HTML instead of JSON. Check server configuration.',
        };
      }

      // Safe JSON decode
      final data = _safeJsonDecode(response.body);

      // Check if decode failed
      if (data is Map && data['rawError'] != null) {
        return {
          'success': false,
          'message': _extractMessage(data, 'Invalid server response'),
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Validate required fields exist
        if (data['accessToken'] == null) {
          print('⚠️ Missing accessToken in response');
          return {
            'success': false,
            'message': 'Server response missing access token',
          };
        }

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
      print('❌ Process Response Error: $e');
      print('📍 Stack: $stackTrace');
      return {
        'success': false,
        'message': 'Kesalahan memproses data: ${e.toString()}',
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

      final response = await http
          .post(
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
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - server tidak merespon');
        },
      );

      return _processResponse(
        response: response,
        successMessage: 'Registrasi berhasil',
        errorMessage: 'Registrasi gagal',
      );
    } catch (e, stackTrace) {
      print('❌ Register Error: $e');
      print('📍 Stack: $stackTrace');

      String errorMessage = 'Koneksi gagal';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Server tidak merespon, coba lagi';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak dapat terhubung ke server';
      }

      return {
        'success': false,
        'message': '$errorMessage: $e',
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

      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - server tidak merespon');
        },
      );

      return _processResponse(
        response: response,
        successMessage: 'Login berhasil',
        errorMessage: 'Login gagal',
      );
    } catch (e, stackTrace) {
      print('❌ Login Error: $e');
      print('📍 Stack: $stackTrace');

      String errorMessage = 'Koneksi gagal';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Server tidak merespon, coba lagi';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak dapat terhubung ke server';
      }

      return {
        'success': false,
        'message': '$errorMessage: $e',
      };
    }
  }

  // ==================== GOOGLE SIGN IN ====================
  static Future<Map<String, dynamic>> googleSignIn(
      Map<String, dynamic> userData) async {
    try {
      print('📤 Google Sign-In for: ${userData['email']}');

      // Validate and normalize input data
      final requestBody = {
        'email': _extractString(userData['email']),
        'name': _extractString(userData['name']),
        'avatar': _extractString(userData['avatar']),
        'idToken': _extractString(userData['idToken']),
        'accessToken': _extractString(userData['accessToken']),
      };

      // Validate required fields
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

      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/google-signin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - server tidak merespon');
        },
      );

      return _processResponse(
        response: response,
        successMessage: 'Login dengan Google berhasil',
        errorMessage: 'Login dengan Google gagal',
      );
    } catch (e, stackTrace) {
      print('❌ Google Sign-In Error: $e');
      print('📍 Stack: $stackTrace');

      String errorMessage = 'Koneksi gagal';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Server tidak merespon, coba lagi';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak dapat terhubung ke server';
      }

      return {
        'success': false,
        'message': '$errorMessage: $e',
      };
    }
  }

  // ==================== REFRESH TOKEN ====================
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'refreshToken': refreshToken,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = _safeJsonDecode(response.body);

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

  // ==================== LOGOUT ====================
  static Future<Map<String, dynamic>> logout({
    required String token,
    String? refreshToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'refreshToken': refreshToken,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = _safeJsonDecode(response.body);

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
