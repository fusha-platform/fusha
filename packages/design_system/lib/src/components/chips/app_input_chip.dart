import 'package:material_ui/material_ui.dart';

import '../../foundation/radius/app_radius.dart';
import '../../theme/extensions/app_theme_extensions.dart';

class AppInputChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final Widget? avatar;
  final bool enabled;
  final Color? backgroundColor;

  const AppInputChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.avatar,
    this.enabled = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InputChip(
      label: Text(label),
      avatar: avatar,
      onDeleted: enabled ? onDeleted : null,
      deleteIcon: const Icon(
        Icons.close_rounded,
        size: 16,
      ),
      backgroundColor: backgroundColor ?? colors.elevatedSurface,
      disabledColor: colors.disabled.withValues(alpha: 0.12),
      side: BorderSide(
        color: colors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      labelStyle: TextStyle(
        color: enabled ? colors.primaryText : colors.disabled,
      ),
    );
  }
}