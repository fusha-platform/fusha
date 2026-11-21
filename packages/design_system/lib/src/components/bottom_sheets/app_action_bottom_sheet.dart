import 'package:flutter/material.dart';

import '../../foundation/radius/app_radius.dart';
import '../../theme/extensions/app_theme_extensions.dart';
import 'app_bottom_sheet.dart';

class AppBottomSheetAction {
  const AppBottomSheetAction({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.subtitle,
    this.isDestructive = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;
}

class AppActionBottomSheet extends StatelessWidget {
  const AppActionBottomSheet({
    super.key,
    required this.title,
    required this.actions,
    this.description,
  });

  final String title;
  final String? description;
  final List<AppBottomSheetAction> actions;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<AppBottomSheetAction> actions,
    String? description,
  }) {
    return AppBottomSheet.show<void>(
      context: context,
      builder: (_) => AppActionBottomSheet(
        title: title,
        description: description,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBottomSheet(
      title: title,
      description: description,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < actions.length; index++) ...[
            _ActionTile(action: actions[index]),
            if (index != actions.length - 1)
              Divider(height: 1, color: colors.divider),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});

  final AppBottomSheetAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    final foregroundColor = action.isDestructive
        ? colors.error
        : colors.primaryText;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color:
                (action.isDestructive ? colors.error : theme.colorScheme.primary)
                    .withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: Icon(action.icon, color: foregroundColor, size: 20),
        ),
        title: Text(
          action.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: action.subtitle == null
            ? null
            : Text(
                action.subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.secondaryText,
                ),
              ),
        onTap: () {
          Navigator.of(context).pop();
          action.onPressed();
        },
      ),
    );
  }
}
