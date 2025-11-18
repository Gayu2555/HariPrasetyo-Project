// lib/provider/user_provider.dart
import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String _userName = 'Guest';
  String _userImage =
      'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1740&q=80';

  String get userName => _userName;
  String get userImage => _userImage;

  // Method untuk set user data (misalnya setelah login)
  void setUserData(String name, String image) {
    _userName = name;
    _userImage = image;
    notifyListeners();
  }

  // Method untuk get greeting berdasarkan waktu
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning 👋';
    } else if (hour < 17) {
      return 'Good Afternoon 👋';
    } else if (hour < 21) {
      return 'Good Evening 👋';
    } else {
      return 'Good Night 🌙';
    }
  }

  // Method untuk logout
  void logout() {
    _userName = 'Guest';
    _userImage =
        'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1740&q=80';
    notifyListeners();
  }
}
