import 'package:flutter/material.dart';

import '../../theme/extensions/app_theme_extensions.dart';
import 'app_bottom_sheet.dart';

class AppBottomSheetOption<T> {
  const AppBottomSheetOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });

  final T value;
  final String label;
  final String? description;
  final IconData? icon;
}

class AppSelectionBottomSheet<T> extends StatelessWidget {
  const AppSelectionBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.onSelected,
    this.description,
    this.selectedValue,
  });

  final String title;
  final String? description;
  final List<AppBottomSheetOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T> onSelected;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<AppBottomSheetOption<T>> options,
    String? description,
    T? selectedValue,
  }) {
    return AppBottomSheet.show<T>(
      context: context,
      builder: (sheetContext) {
        return AppSelectionBottomSheet<T>(
          title: title,
          description: description,
          options: options,
          selectedValue: selectedValue,
          onSelected: (value) {
            Navigator.of(sheetContext).pop(value);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppBottomSheet(
      title: title,
      description: description,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: option.icon == null
                    ? null
                    : Icon(
                  option.icon,
                  color: colors.secondaryText,
                ),
                title: Text(
                  option.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.primaryText,
                  ),
                ),
                subtitle: option.description == null
                    ? null
                    : Text(
                  option.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
                trailing: _isSelected(option.value)
                    ? Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                )
                    : null,
                onTap: () => onSelected(option.value),
              ),
            ),
        ],
      ),
    );
  }

  bool _isSelected(T value) {
    return selectedValue == value;
  }
}