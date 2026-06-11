// lib/theme.dart
import 'package:flutter/material.dart';

const kBg       = Color(0xFF0F1117);
const kSurface  = Color(0xFF1A1D27);
const kSurface2 = Color(0xFF222535);
const kBorder   = Color(0xFF2E3147);
const kPrimary  = Color(0xFF1DB88A);
const kPrimaryDk= Color(0xFF0F6E56);
const kText     = Color(0xFFE8EAF0);
const kText2    = Color(0xFF8B8FA8);
const kGreen    = Color(0xFF1DB88A);
const kGreenBg  = Color(0xFF0D2E24);
const kRed      = Color(0xFFE05555);
const kRedBg    = Color(0xFF2E1515);
const kAmber    = Color(0xFFE0A030);
const kAmberBg  = Color(0xFF2E2210);
const kBlue     = Color(0xFF4A9EE0);
const kBlueBg   = Color(0xFF102030);

Color scoreColor(int s) {
  if (s >= 85) return kGreen;
  if (s >= 70) return kBlue;
  if (s >= 55) return kAmber;
  return kRed;
}

String scoreLabel(int s) {
  if (s >= 85) return 'Elite';
  if (s >= 70) return 'Strong';
  if (s >= 55) return 'Tradable';
  return 'Skip';
}

Color outcomeColor(String o) {
  switch (o) {
    case 'TP Hit':    return kGreen;
    case 'SL Hit':    return kRed;
    case 'Partial':   return kAmber;
    case 'Breakeven': return kBlue;
    default:          return kText2;
  }
}

ThemeData appTheme() => ThemeData(
  colorScheme: const ColorScheme.dark(
    primary:   kPrimary,
    surface:   kSurface,
    onSurface: kText,
  ),
  scaffoldBackgroundColor: kBg,
  appBarTheme: const AppBarTheme(
    backgroundColor: kSurface,
    foregroundColor: kText,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w600),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kSurface,
    selectedItemColor: kPrimary,
    unselectedItemColor: kText2,
    type: BottomNavigationBarType.fixed,
  ),
  cardTheme: CardThemeData(
    color: kSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: kBorder),
    ),
    elevation: 0,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kSurface2,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: kPrimary, width: 1.5),
    ),
    hintStyle: const TextStyle(color: kText2),
    labelStyle: const TextStyle(color: kText2),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: kText),
    bodySmall:  TextStyle(color: kText2),
  ),
  dividerColor: kBorder,
  useMaterial3: true,
);
