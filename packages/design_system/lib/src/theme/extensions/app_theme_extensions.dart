import 'package:design_system/src/theme/extensions/app_colors_extension.dart';
import 'package:material_ui/material_ui.dart';

extension AppThemeExtensions on BuildContext {
  AppColorsExtension get appColors {
    return Theme.of(this).extension<AppColorsExtension>()!;
  }
}
