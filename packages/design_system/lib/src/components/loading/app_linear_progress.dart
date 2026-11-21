import 'package:flutter/material.dart';

class AppLinearProgress extends StatelessWidget {
  const AppLinearProgress({
    super.key,
    this.value,
    this.color,
    this.backgroundColor,
    this.minHeight = 4,
    this.borderRadius = 4,
    this.semanticsLabel,
  }) : assert(value == null || (value >= 0 && value <= 1));

  final double? value;
  final Color? color;
  final Color? backgroundColor;
  final double minHeight;
  final double borderRadius;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: LinearProgressIndicator(
        value: value,
        color: color ?? theme.colorScheme.primary,
        backgroundColor:
        backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        minHeight: minHeight,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}