import 'package:material_ui/material_ui.dart';

import 'app_font_weights.dart';

abstract final class AppTextStyles {
  AppTextStyles._();

  static TextTheme build({
    required String fontFamily,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: AppFontWeights.bold,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 30,
        fontWeight: AppFontWeights.bold,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: AppFontWeights.semiBold,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: AppFontWeights.semiBold,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: AppFontWeights.semiBold,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: AppFontWeights.medium,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: AppFontWeights.regular,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: AppFontWeights.regular,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: AppFontWeights.regular,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: AppFontWeights.semiBold,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: AppFontWeights.medium,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: AppFontWeights.regular,
      ),
    );
  }
}