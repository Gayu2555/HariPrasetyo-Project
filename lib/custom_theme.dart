import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTheme {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: const Color(0xfffe0000),
    textTheme: GoogleFonts.openSansTextTheme().apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    primaryTextTheme: GoogleFonts.openSansTextTheme().apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    splashColor: const Color(0xfffe0101),
    iconTheme: const IconThemeData(color: Color(0xffff6b6b)),
  );
}
