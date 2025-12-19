import 'package:flutter/material.dart';

class AppColors {
  // BASE PALETTE (PRIVATE)
  static const Color _veryLightIndigo = Color(0xFF4E4C67);
  static const Color _lightIndigo = Color(0xFF242244);
  static const Color _indigo = Color(0xFF191831);
  static const Color _darkIndigo = Color(0xFF111024);
  static const Color _pastelYellow = Color(0xFFD3B53E);
  static const Color _yellow = Color(0xFFFFD500);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _red = Color(0xFFC00F0C);
  static const Color _orange = Color(0xFFBF6A02);
  static const Color _green = Color(0xFF14AE5C);

  // Main Backgrounds
  static const Color bg = _indigo;          // App Background
  static const Color cardBg = _lightIndigo; // Cards/Containers

  // Accents & Buttons
  static const Color primary = _pastelYellow;   // Button
  static const Color buttonText = _darkIndigo;  // Button Text

  // Typography
  static const Color textHeading = _pastelYellow;       // Text Heading
  static const Color textPrimary = _white;              // Text Body
  static const Color textSecondary = _veryLightIndigo;  // Text Subtitles, etc.

  // Navigation
  static const Color navBarBg = _darkIndigo;      // NavBar Background
  static const Color navSelected = _pastelYellow; // Selected Icon NavBar
  static const Color navUnselected = _white;      // Unselected Icon NavBar

  // Utility
  static const Color statusRed = _red;
  static const Color statusOrange = _orange;
  static const Color statusGreen = _green;
  static const Color statusGrayIndigo = _veryLightIndigo;

  // KuLatih Logo
  static const Color logoWhite = _white;   // Ku
  static const Color logoYellow = _yellow; // Latih
}
