import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Do not depend on Sizer in the theme definition; ThemeData may be
// constructed before Sizer is initialized. Use fixed font sizes here.

class CustomTheme {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: const Color(0xff084f57),
    // Use GoogleFonts to set the Open Sans text theme globally. This
    // ensures fonts are available consistently and avoids per-widget
    // font configuration issues.
    textTheme: GoogleFonts.openSansTextTheme().apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    primaryTextTheme: GoogleFonts.openSansTextTheme().apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    splashColor: const Color(0xff084f57),
    iconTheme: const IconThemeData(color: Color(0xff084f57)),
  );
}
