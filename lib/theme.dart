import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // Potrebné pre PlatformDispatcher
import 'package:flutter/material.dart';

class AppTheme {
  // Definujeme seed farbu na jednom mieste
  static const _seedColor = Colors.deepPurple;

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      surface: const Color(0xFFFDF7FF),
    ),

    textTheme: GoogleFonts.plusJakartaSansTextTheme(),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 2,
      backgroundColor: Colors.transparent,
    ),

    // --- OPRAVA TU: CardTheme -> CardThemeData ---
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xFFF3EDF7),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      backgroundColor: Colors.white,
      modalBarrierColor: Colors.black54,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 2,
    ),
    // V tmavom režime chceme, aby povrchy neboli úplne čierne, ale jemne šedé/fialové
    scaffoldBackgroundColor: const Color(0xFF141218),
  );
}

// ThemeProvider ostáva rovnaký, je napísaný správne a efektívne.
class ThemeProvider extends ChangeNotifier {
  // Pridáme stavy: Light, Dark, alebo System
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Pomocná funkcia, ktorá nám povie, či je aktuálne aktívny tmavý režim
  // (buď je vynútený, alebo je nastavený systémový a systém je v Dark móde)
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Prepínanie cyklicky: System -> Light -> Dark
  void toggleTheme() {
    if (_themeMode == ThemeMode.system) {
      _themeMode = ThemeMode.light;
    } else if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }
}