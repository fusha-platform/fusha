import 'package:flutter/material.dart';

enum AppProgressSize {
  small,
  medium,
  large,
}

class AppCircularProgress extends StatelessWidget {
  const AppCircularProgress({
    super.key,
    this.size = AppProgressSize.medium,
    this.value,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 3,
    this.semanticsLabel,
  });

  final AppProgressSize size;
  final double? value;
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final String? semanticsLabel;

  double get _dimension {
    return switch (size) {
      AppProgressSize.small => 16,
      AppProgressSize.medium => 24,
      AppProgressSize.large => 40,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox.square(
      dimension: _dimension,
      child: CircularProgressIndicator(
        value: value,
        color: color ?? theme.colorScheme.primary,
        backgroundColor: backgroundColor,
        strokeWidth: strokeWidth,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}