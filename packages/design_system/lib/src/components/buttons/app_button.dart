
import 'package:material_ui/material_ui.dart';

import '../../foundation/motion/app_motion.dart';
import '../../foundation/motion/app_motion_curves.dart';
import '../../foundation/motion/app_motion_durations.dart';
import '../../foundation/radius/app_radius.dart';
import 'app_button_size.dart';
import 'app_button_type.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  double get _height {
    return switch (size) {
      AppButtonSize.small => 36,
      AppButtonSize.medium => 48,
      AppButtonSize.large => 56,
    };
  }

  double get _horizontalPadding {
    return switch (size) {
      AppButtonSize.small => 12,
      AppButtonSize.medium => 16,
      AppButtonSize.large => 24,
    };
  }

  double get _iconSize {
    return switch (size) {
      AppButtonSize.small => 16,
      AppButtonSize.medium => 18,
      AppButtonSize.large => 20,
    };
  }

  double get _fontSize {
    return switch (size) {
      AppButtonSize.small => 12,
      AppButtonSize.medium => 14,
      AppButtonSize.large => 16,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final buttonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(isExpanded ? double.infinity : 0, _height),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: _horizontalPadding),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      animationDuration: AppMotion.duration(
        context,
        AppMotionDurations.normal,
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    final foregroundColor = switch (type) {
      AppButtonType.primary => colorScheme.onPrimary,
      AppButtonType.secondary => colorScheme.onSecondaryContainer,
      AppButtonType.outlined || AppButtonType.text => colorScheme.primary,
    };

    final content = _buildContent(
      context: context,
      foregroundColor: foregroundColor,
    );

    final effectiveOnPressed = isLoading ? null : onPressed;

    final Widget button = switch (type) {
      AppButtonType.primary => FilledButton(
        onPressed: effectiveOnPressed,
        style: buttonStyle,
        child: content,
      ),
      AppButtonType.secondary => FilledButton(
        onPressed: effectiveOnPressed,
        style: buttonStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.secondaryContainer,
          ),
          foregroundColor: WidgetStatePropertyAll(
            colorScheme.onSecondaryContainer,
          ),
        ),
        child: content,
      ),
      AppButtonType.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: buttonStyle,
        child: content,
      ),
      AppButtonType.text => TextButton(
        onPressed: effectiveOnPressed,
        style: buttonStyle,
        child: content,
      ),
    };

    return button;
  }

  Widget _buildContent({
    required BuildContext context,
    required Color foregroundColor,
  }) {
    return AnimatedSwitcher(
      duration: AppMotion.duration(
        context,
        AppMotionDurations.fast,
      ),
      switchInCurve: AppMotion.curve(
        context,
        AppMotionCurves.enter,
      ),
      child: Row(
        key: ValueKey(isLoading),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: _iconSize,
              height: _iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foregroundColor,
              ),
            )
          else if (icon != null)
            Icon(
              icon,
              size: _iconSize,
            ),
          if (isLoading || icon != null)
            const SizedBox(width: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
