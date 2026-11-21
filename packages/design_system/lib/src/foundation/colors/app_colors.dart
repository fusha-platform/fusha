
import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Brand Colors
  static const Color navy = Color(0xFF123B62);
  static const Color teal = Color(0xFF12B8A6);
  static const Color orange = Color(0xFFFF9B54);

  // Light Theme
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF182433);

  // Dark Theme
  static const Color darkBackground = Color(0xFF101923);
  static const Color darkSurface = Color(0xFF192633);
  static const Color darkElevated = Color(0xFF223342);
  static const Color darkText = Color(0xFFF5F7FA);

  // Semantic Colors
  static const Color success = Color(0xFF16A36A);
  static const Color error = Color(0xFFDC4545);
  static const Color warning = Color(0xFFFF9B54);
  static const Color info = Color(0xFF1657D6);
}
