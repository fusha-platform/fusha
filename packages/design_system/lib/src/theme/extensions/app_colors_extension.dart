import 'package:design_system/src/foundation/colors/app_colors.dart';
import 'package:flutter/material.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.elevatedSurface,
    required this.primaryText,
    required this.secondaryText,
    required this.disabled,
    required this.border,
    required this.divider,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });

  final Color background;
  final Color surface;
  final Color elevatedSurface;

  final Color primaryText;
  final Color secondaryText;
  final Color disabled;

  final Color border;
  final Color divider;

  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  static const light = AppColorsExtension(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    elevatedSurface: Color(0xFFEEF2F6),
    primaryText: AppColors.lightText,
    secondaryText: Color(0xFF64748B),
    disabled: Color(0xFFADB5BD),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFEDF0F4),
    success: AppColors.success,
    error: AppColors.error,
    warning: AppColors.warning,
    info: AppColors.info,
  );

  static const dark = AppColorsExtension(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    elevatedSurface: AppColors.darkElevated,
    primaryText: AppColors.darkText,
    secondaryText: Color(0xFFADB9C5),
    disabled: Color(0xFF64748B),
    border: Color(0xFF344454),
    divider: Color(0xFF2B3B49),
    success: AppColors.success,
    error: AppColors.error,
    warning: AppColors.warning,
    info: AppColors.info,
  );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? elevatedSurface,
    Color? primaryText,
    Color? secondaryText,
    Color? disabled,
    Color? border,
    Color? divider,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      disabled: disabled ?? this.disabled,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppColorsExtension lerp(
      covariant ThemeExtension<AppColorsExtension>? other,
      double t,
      ) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevatedSurface: Color.lerp(
        elevatedSurface,
        other.elevatedSurface,
        t,
      )!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(
        secondaryText,
        other.secondaryText,
        t,
      )!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}