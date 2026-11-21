import 'package:design_system/src/theme/extensions/app_colors_extension.dart';
import 'package:flutter/material.dart';

extension AppThemeExtensions on BuildContext {
  AppColorsExtension get appColors {
    return Theme.of(this).extension<AppColorsExtension>()!;
  }
}
