import 'package:material_ui/material_ui.dart';

import '../../foundation/motion/app_motion.dart';
import '../../foundation/motion/app_motion_curves.dart';
import '../../foundation/motion/app_motion_durations.dart';
import '../../foundation/radius/app_radius.dart';
import '../../theme/extensions/app_theme_extensions.dart';
import 'app_dialog_type.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.description,
    this.type = AppDialogType.info,
    this.icon,
    this.content,
    this.actions,
    this.showCloseButton = false,
  });

  final String title;
  final String? description;
  final AppDialogType type;
  final IconData? icon;
  final Widget? content;
  final Widget? actions;
  final bool showCloseButton;

  /// Opens a dialog with the shared soft transition.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    final duration = AppMotion.duration(
      context,
      AppMotionDurations.medium,
    );

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: duration,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Builder(builder: builder),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = AppMotion.curve(
          context,
          AppMotionCurves.enter,
        );

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  Color _getTypeColor(BuildContext context) {
    final colors = context.appColors;

    return switch (type) {
      AppDialogType.info => colors.info,
      AppDialogType.success => colors.success,
      AppDialogType.warning => colors.warning,
      AppDialogType.error => colors.error,
    };
  }

  IconData get _typeIcon {
    return switch (type) {
      AppDialogType.info => Icons.info_outline_rounded,
      AppDialogType.success => Icons.check_circle_outline_rounded,
      AppDialogType.warning => Icons.warning_amber_rounded,
      AppDialogType.error => Icons.error_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final typeColor = _getTypeColor(context);

    return Dialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon ?? _typeIcon,
                      color: typeColor,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (showCloseButton)
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      icon: const Icon(Icons.close_rounded),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ],
              if (content != null) ...[
                const SizedBox(height: 20),
                content!,
              ],
              if (actions != null) ...[
                const SizedBox(height: 24),
                actions!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}