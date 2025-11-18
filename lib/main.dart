// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/login.dart';
import 'package:recipe_app/provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:recipe_app/custom_theme.dart';
import 'package:recipe_app/screens/home_screen.dart';
import 'package:recipe_app/provider/user_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListOfRecipes()),
        ChangeNotifierProvider(create: (_) => SavedProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(), // Hanya child yang diperlukan di sini
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Recipe App',
          debugShowCheckedModeBanner: false,
          theme: CustomTheme.lightTheme,
          // Pilih salah satu: Login() atau HomeScreen() sebagai halaman awal
          home: const Login(), // atau home: const HomeScreen(),
          navigatorKey: GlobalKey<NavigatorState>(),
        );
      },
    );
  }
}
