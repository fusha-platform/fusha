import 'package:flutter/material.dart';

import '../../foundation/motion/app_motion.dart';
import '../../foundation/motion/app_motion_durations.dart';
import '../../foundation/radius/app_radius.dart';
import '../../theme/extensions/app_theme_extensions.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final bool enabled;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = selected
        ? colorScheme.primary.withValues(alpha: 0.12)
        : colors.surface;

    final foregroundColor = selected
        ? colorScheme.primary
        : colors.secondaryText;

    return AnimatedContainer(
      duration: AppMotion.duration(
        context,
        AppMotionDurations.normal,
      ),
      curve: AppMotion.curve(context, Curves.easeInOut),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: enabled ? onSelected : null,
        avatar: icon == null
            ? null
            : Icon(
          icon,
          size: 16,
          color: foregroundColor,
        ),
        showCheckmark: selected,
        backgroundColor: backgroundColor,
        selectedColor: backgroundColor,
        disabledColor: colors.disabled.withValues(alpha: 0.12),
        checkmarkColor: colorScheme.primary,
        side: BorderSide(
          color: selected ? colorScheme.primary : colors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        labelStyle: TextStyle(
          color: enabled ? foregroundColor : colors.disabled,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}