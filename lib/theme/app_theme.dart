import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Цветовая палитра - Черный и Токсично-желтый
  static const Color pureBlack = Color(0xFF000000); // Чистый черный
  static const Color almostBlack = Color(0xFF0A0A0A); // Почти черный
  static const Color darkGray = Color(0xFF1A1A1A); // Темно-серый (для карточек)
  static const Color mediumGray = Color(0xFF2A2A2A); // Средне-серый
  static const Color toxicYellow = Color(0xFFCCFF00); // Токсично-желтый (основной акцент)
  static const Color darkYellow = Color(0xFFAADD00); // Темнее желтый
  static const Color brightYellow = Color(0xFFDDFF33); // Светлее желтый
  static const Color mutedYellow = Color(0xFF999900); // Приглушенный желтый для текста

  // Основная тема
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: pureBlack,

      colorScheme: ColorScheme.dark(
        primary: toxicYellow,
        secondary: darkYellow,
        surface: darkGray,
        onPrimary: pureBlack,
        onSecondary: pureBlack,
        onSurface: Colors.white,
      ),

      // AppBar тема
      appBarTheme: AppBarTheme(
        backgroundColor: almostBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          color: toxicYellow,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: toxicYellow,
          foregroundColor: pureBlack,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Текстовые поля
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkGray,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: mediumGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: mediumGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: toxicYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        labelStyle: GoogleFonts.montserrat(color: toxicYellow, fontSize: 16),
        hintStyle: GoogleFonts.montserrat(color: Colors.grey.shade500, fontSize: 16),
      ),

      // Карточки
      cardTheme: CardThemeData(
        color: darkGray,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // Текст
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        headlineLarge: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineSmall: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 17,
        ),
        bodyMedium: GoogleFonts.montserrat(
          color: Colors.grey.shade300,
          fontSize: 15,
        ),
        bodySmall: GoogleFonts.montserrat(
          color: Colors.grey.shade400,
          fontSize: 13,
        ),
        titleLarge: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.montserrat(
          color: Colors.grey.shade300,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.montserrat(
          color: Colors.grey.shade400,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Прогресс бар
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: toxicYellow,
        linearTrackColor: mediumGray,
        linearMinHeight: 8,
      ),
    );
  }

  // Градиент для фонов
  static LinearGradient get backgroundGradient {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        pureBlack,
        almostBlack,
        pureBlack,
      ],
    );
  }
}