import 'package:design_system/src/foundation/typography/app_font_families.dart';
import 'package:design_system/src/foundation/typography/app_text_styles.dart';
import 'package:flutter/material.dart';

abstract final class AppTypography {
  AppTypography._();

  static TextTheme build(Locale locale) {
    final isArabic = locale.languageCode == 'ar';

    return AppTextStyles.build(
      fontFamily: isArabic ? AppFontFamilies.arabic : AppFontFamilies.english,
    );
  }
}
