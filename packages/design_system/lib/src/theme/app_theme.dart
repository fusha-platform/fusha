import 'package:material_ui/material_ui.dart';

import '../foundation/colors/app_color_scheme.dart';
import '../foundation/colors/app_colors.dart';
import 'app_component_themes.dart';
import 'app_typography.dart';
import 'extensions/app_colors_extension.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData light({required Locale locale}) {
    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: AppColorScheme.light,
      backgroundColor: AppColors.lightBackground,
      locale: locale,
      colorsExtension: AppColorsExtension.light,
    );
  }

  static ThemeData dark({required Locale locale}) {
    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: AppColorScheme.dark,
      backgroundColor: AppColors.darkBackground,
      locale: locale,
      colorsExtension: AppColorsExtension.dark,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color backgroundColor,
    required Locale locale,
    required AppColorsExtension colorsExtension,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: AppTypography.build(locale),
      extensions: [colorsExtension],
      elevatedButtonTheme: AppComponentThemes.elevatedButton,
      outlinedButtonTheme: AppComponentThemes.outlinedButton,
      textButtonTheme: AppComponentThemes.textButton,
      inputDecorationTheme: AppComponentThemes.inputDecoration,
      cardTheme: AppComponentThemes.card,
    );
  }
}