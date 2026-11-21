import 'package:material_ui/material_ui.dart';

import '../buttons/app_button_type.dart';
import 'app_dialog.dart';
import 'app_dialog_actions.dart';
import 'app_dialog_type.dart';

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.type = AppDialogType.warning,
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final AppDialogType type;
  final bool isDestructive;

  /// Returns:
  /// - true: user confirmed.
  /// - false: user cancelled.
  /// - null: dialog was dismissed.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    AppDialogType type = AppDialogType.warning,
    bool isDestructive = false,
    bool barrierDismissible = true,
  }) {
    return AppDialog.show<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        type: type,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      description: message,
      type: type,
      actions: AppDialogActions(
        primaryLabel: confirmLabel,
        secondaryLabel: cancelLabel,
        primaryButtonType: isDestructive
            ? AppButtonType.outlined
            : AppButtonType.primary,
        onPrimaryPressed: () => Navigator.of(context).pop(true),
        onSecondaryPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }
}