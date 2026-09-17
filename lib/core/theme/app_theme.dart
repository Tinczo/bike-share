import 'package:flutter/material.dart';

class AppPalette {
  static const primaryBlue = Color(0xFF155DFC);
  static const orange = Color(0xFFFF6900);
  static const inputBackground = Color(0xFFF3F3F5);
  static const labelColor = Color(0xFF0A0A0A);
  static const hintColor = Color(0xFF717182);
  static const subtitleBlue = Color(0xFFDBEAFE);
  static const paragraphColor = Color(0xFF4A5565);

  // Warning/info banner colors
  static const warningBackground = Color(0xFFFFF7ED);
  static const warningBorder = Color(0xFFFFD6A7);
  static const warningOrange = Color(0xFFEA580C);

  // Selection colors
  static const selectedBlueBackground = Color(0xFFEFF6FF);
  static const tileBorder = Color(0xFFE5E7EB);

  // Scaffold background
  static const scaffoldGray = Color(0xFFF3F4F6);

  // Wallet screen colors
  static const tileBackground = Color(0xFFF9FAFB);
  static const expenseRed = Color(0xFFE7000B);
  static const incomeGreen = Color(0xFF00A63E);
  static const expenseIconBg = Color(0xFFFEF2F2);
  static const incomeIconBg = Color(0xFFF0FDF4);
  static const gradientBlueEnd = Color(0xFF1447E6);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.primaryBlue,
        primary: AppPalette.primaryBlue,
        secondary: AppPalette.orange,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.inputBackground,
        hintStyle: const TextStyle(fontSize: 16, color: AppPalette.hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppPalette.primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red, // Default error color or custom
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.primaryBlue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}

ThemeData appTheme = AppTheme.lightTheme;
ThemeData darkTheme = AppTheme.darkTheme;
