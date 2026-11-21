import 'package:design_system/src/components/badges/app_badge_type.dart';
import 'package:design_system/src/theme/extensions/app_theme_extensions.dart';
import 'package:flutter/material.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.type = AppBadgeType.neutral,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 5,
    ),
    this.fontSize = 12,
    this.iconSize = 14,
  });

  final String label;
  final AppBadgeType type;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double iconSize;

  Color _foregroundColor(BuildContext context) {
    if (foregroundColor != null) return foregroundColor!;

    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return switch (type) {
      AppBadgeType.primary => scheme.primary,
      AppBadgeType.secondary => scheme.secondary,
      AppBadgeType.success => colors.success,
      AppBadgeType.warning => colors.warning,
      AppBadgeType.error => colors.error,
      AppBadgeType.info => colors.info,
      AppBadgeType.neutral => colors.secondaryText,
    };
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _foregroundColor(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize,
              color: foreground,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}