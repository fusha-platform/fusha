import 'package:material_ui/material_ui.dart';

import '../../foundation/motion/app_motion.dart';
import '../../foundation/motion/app_motion_durations.dart';
import '../../foundation/radius/app_radius.dart';
import '../../theme/extensions/app_theme_extensions.dart';

class AppChoiceChip<T> extends StatelessWidget {
  final String label;
  final T value;
  final T selectedValue;
  final ValueChanged<T>? onSelected;
  final IconData? icon;
  final bool enabled;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    final selected = value == selectedValue;

    final foregroundColor = selected
        ? colorScheme.primary
        : colors.secondaryText;

    return AnimatedContainer(
      duration: AppMotion.duration(
        context,
        AppMotionDurations.normal,
      ),
      curve: AppMotion.curve(context, Curves.easeInOut),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: enabled && onSelected != null
            ? (_) => onSelected!(value)
            : null,
        avatar: icon == null
            ? null
            : Icon(
          icon,
          size: 16,
          color: foregroundColor,
        ),
        backgroundColor: colors.surface,
        selectedColor: colorScheme.primary.withValues(alpha: 0.12),
        disabledColor: colors.disabled.withValues(alpha: 0.12),
        showCheckmark: false,
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