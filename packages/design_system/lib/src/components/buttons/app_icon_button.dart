
import 'package:material_ui/material_ui.dart';

import '../../foundation/motion/app_motion.dart';
import '../../foundation/motion/app_motion_durations.dart';
import '../../foundation/radius/app_radius.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 44,
    this.iconSize = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedContainer(
      duration: AppMotion.duration(
        context,
        AppMotionDurations.normal,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!),
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: BoxConstraints.tightFor(
          width: size,
          height: size,
        ),
        padding: EdgeInsets.zero,
        iconSize: iconSize,
        color: foregroundColor ?? colors.onSurface,
        icon: Icon(icon),
      ),
    );
  }
}
