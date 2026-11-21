import 'package:flutter/material.dart';

class AppNotificationBadge extends StatelessWidget {
  const AppNotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.maxCount = 99,
    this.showZero = false,
    this.backgroundColor,
    this.foregroundColor,
    this.offset = const Offset(4, -4),
  }) : assert(maxCount > 0);

  final Widget child;
  final int count;
  final int maxCount;
  final bool showZero;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Offset offset;

  bool get _shouldShow => count > 0 || showZero;

  String get _label {
    return count > maxCount ? '$maxCount+' : '$count';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (_shouldShow)
          Positioned(
            top: offset.dy,
            right: offset.dx,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor ?? theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _label,
                  style: TextStyle(
                    color: foregroundColor ?? theme.colorScheme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}