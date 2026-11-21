
import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

abstract final class AppColorScheme {
  AppColorScheme._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.navy,
    onPrimary: Colors.white,
    secondary: AppColors.teal,
    onSecondary: AppColors.darkText,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightText,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.teal,
    onPrimary: AppColors.darkBackground,
    secondary: AppColors.orange,
    onSecondary: AppColors.darkBackground,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkText,
  );
}
