import 'package:design_system/src/components/loading/app_shimmer.dart';
import 'package:flutter/material.dart';

enum AppSkeletonShape {
  rectangle,
  rounded,
  circle,
}

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.shape = AppSkeletonShape.rounded,
    this.borderRadius = 8,
    this.color,
    this.highlightColor,
    this.animate = true,
  }) : assert(width == null || width >= 0),
        assert(height >= 0);

  final double? width;
  final double height;
  final AppSkeletonShape shape;
  final double borderRadius;
  final Color? color;
  final Color? highlightColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseColor =
        color ?? theme.colorScheme.surfaceContainerHighest;

    final skeleton = SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: baseColor,
          shape: shape == AppSkeletonShape.circle
              ? BoxShape.circle
              : BoxShape.rectangle,
          borderRadius: shape == AppSkeletonShape.rounded
              ? BorderRadius.circular(borderRadius)
              : null,
        ),
      ),
    );

    if (!animate) return skeleton;

    return AppShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: skeleton,
    );
  }
}