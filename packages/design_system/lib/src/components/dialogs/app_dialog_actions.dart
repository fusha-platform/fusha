import 'package:flutter/material.dart';

import '../buttons/app_button.dart';
import '../buttons/app_button_size.dart';
import '../buttons/app_button_type.dart';

class AppDialogActions extends StatelessWidget {
  const AppDialogActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.primaryButtonType = AppButtonType.primary,
    this.isLoading = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;

  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  final AppButtonType primaryButtonType;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (secondaryLabel != null)
          AppButton(
            label: secondaryLabel!,
            onPressed: onSecondaryPressed,
            type: AppButtonType.outlined,
            size: AppButtonSize.medium,
          ),
        AppButton(
          label: primaryLabel,
          onPressed: onPrimaryPressed,
          type: primaryButtonType,
          size: AppButtonSize.medium,
          isLoading: isLoading,
        ),
      ],
    );
  }
}