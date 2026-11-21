import 'package:design_system/src/components/loading/app_loading.dart';
import 'package:flutter/material.dart';

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.overlayColor,
    this.indicatorColor,
    this.barrierDismissible = false,
  });

  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? overlayColor;
  final Color? indicatorColor;
  final bool barrierDismissible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: !barrierDismissible,
              child: IgnorePointer(
                ignoring: barrierDismissible,
                child: ColoredBox(
                  color: overlayColor ??
                      theme.colorScheme.scrim.withValues(alpha: 0.32),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 240),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AppLoading(
                        message: message,
                        color: indicatorColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}