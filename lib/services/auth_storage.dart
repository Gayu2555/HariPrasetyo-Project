import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';

  // Simpan token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  // Ambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Simpan data user
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user));
  }

  // Ambil data user
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_keyUser);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Logout (hapus semua data)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }
}
