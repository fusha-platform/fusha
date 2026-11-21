import 'package:flutter/material.dart';

import '../../foundation/motion/app_motion.dart';
import '../../foundation/motion/app_motion_durations.dart';
import '../../foundation/radius/app_radius.dart';
import '../../foundation/shadows/app_shadows.dart';
import '../../theme/extensions/app_theme_extensions.dart';
import 'app_card_type.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardType type;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  const AppCard({
    super.key,
    required this.child,
    this.type = AppCardType.filled,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final radius = borderRadius ?? BorderRadius.circular(AppRadius.lg);

    final decoration = BoxDecoration(
      color: backgroundColor ?? colors.surface,
      borderRadius: radius,
      border: type == AppCardType.outlined
          ? Border.all(color: borderColor ?? colors.border)
          : null,
      boxShadow: switch (type) {
        AppCardType.elevated => AppShadows.medium,
        _ => null,
      },
    );

    return AnimatedContainer(
      duration: AppMotion.duration(context, AppMotionDurations.normal),
      curve: AppMotion.curve(context, Curves.easeInOut),
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
