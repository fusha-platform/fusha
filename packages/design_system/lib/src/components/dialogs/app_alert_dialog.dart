import 'package:flutter/material.dart';

import 'app_dialog.dart';
import 'app_dialog_actions.dart';
import 'app_dialog_type.dart';

class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = AppDialogType.info,
    this.buttonLabel = 'OK',
  });

  final String title;
  final String message;
  final AppDialogType type;
  final String buttonLabel;

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    AppDialogType type = AppDialogType.info,
    String buttonLabel = 'OK',
    bool barrierDismissible = true,
  }) {
    return AppDialog.show<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AppAlertDialog(
        title: title,
        message: message,
        type: type,
        buttonLabel: buttonLabel,
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
        primaryLabel: buttonLabel,
        onPrimaryPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }
}