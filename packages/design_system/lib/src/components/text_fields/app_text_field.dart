import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../foundation/radius/app_radius.dart';
import '../../foundation/spacing/app_spacing.dart';
import 'app_text_field_type.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.type = AppTextFieldType.text,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixPressed,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final AppTextFieldType type;

  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;

  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  final bool autocorrect;
  final bool enableSuggestions;
  final bool obscureText;
  TextInputType get _keyboardType {
    return switch (type) {
      AppTextFieldType.text => TextInputType.text,
      AppTextFieldType.email => TextInputType.emailAddress,
      AppTextFieldType.number => TextInputType.number,
      AppTextFieldType.phone => TextInputType.phone,
      AppTextFieldType.multiline => TextInputType.multiline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isMultiline = type == AppTextFieldType.multiline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          keyboardType: _keyboardType,
          textInputAction: textInputAction ??
              (isMultiline
                  ? TextInputAction.newline
                  : TextInputAction.next),
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          maxLines: isMultiline ? maxLines : 1,
          minLines: isMultiline ? minLines ?? 3 : 1,
          maxLength: maxLength,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon),
            suffixIcon: suffixIcon == null
                ? null
                : IconButton(
              onPressed: onSuffixPressed,
              icon: Icon(suffixIcon),
            ),
            filled: true,
            fillColor: enabled
                ? colors.surfaceContainerHighest.withValues(alpha: 0.35)
                : colors.surfaceContainerHighest.withValues(alpha: 0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: colors.outlineVariant,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: colors.outlineVariant,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: colors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: colors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: colors.error,
                width: 1.5,
              ),
            ),
          ),
          obscureText: obscureText,
        ),
      ],
    );
  }
}
