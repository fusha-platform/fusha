import 'package:flutter/material.dart';

import 'app_text_field.dart';

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.label = 'Password',
    this.hintText = 'Enter your password',
    this.errorText,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String label;
  final String hintText;
  final String? errorText;

  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  final bool enabled;
  final TextInputAction textInputAction;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      label: widget.label,
      hintText: widget.hintText,
      errorText: widget.errorText,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      autocorrect: false,
      enableSuggestions: false,
      suffixIcon: _obscureText
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
      onSuffixPressed: _toggleVisibility,
    );
  }
}
