import 'package:material_ui/material_ui.dart';

import '../../foundation/radius/app_radius.dart';
import '../../theme/extensions/app_theme_extensions.dart';
import 'app_chip_type.dart';

class AppChip extends StatelessWidget {
  final String label;
  final AppChipType type;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double iconSize;

  const AppChip({
    super.key,
    required this.label,
    this.type = AppChipType.neutral,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
    this.fontSize = 12,
    this.iconSize = 14,
  });

  Color _backgroundColor(BuildContext context) {
    final colors = context.appColors;

    return backgroundColor ??
        switch (type) {
          AppChipType.primary =>
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          AppChipType.secondary =>
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
          AppChipType.success => colors.success.withValues(alpha: 0.12),
          AppChipType.warning => colors.warning.withValues(alpha: 0.12),
          AppChipType.error => colors.error.withValues(alpha: 0.12),
          AppChipType.info => colors.info.withValues(alpha: 0.12),
          AppChipType.neutral => colors.elevatedSurface,
        };
  }

  Color _foregroundColor(BuildContext context) {
    final colors = context.appColors;

    return foregroundColor ??
        switch (type) {
          AppChipType.primary => Theme.of(context).colorScheme.primary,
          AppChipType.secondary => Theme.of(context).colorScheme.secondary,
          AppChipType.success => colors.success,
          AppChipType.warning => colors.warning,
          AppChipType.error => colors.error,
          AppChipType.info => colors.info,
          AppChipType.neutral => colors.primaryText,
        };
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _foregroundColor(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor(context),
        borderRadius: BorderRadius.circular(AppRadius.full),
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
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}