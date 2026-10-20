
import 'package:flutter/material.dart';

/// Reusable text field for the LIFE+ authentication screens.
///
/// WHY use a custom widget?
/// We avoid repeating the same InputDecoration in login and registration.
/// If we change the field design later, we only need to edit this file.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.autofillHints,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.maxLines = 1,
  });

  // Controller reads and updates the text entered by the user.
  final TextEditingController controller;

  // Text displayed as the field label, e.g. "Email address".
  final String label;

  final String? hint;

  // Validation function supplied by the screen using this widget.
  final String? Function(String?)? validator;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,

      // Password fields must always stay on one line.
      maxLines: obscureText ? 1 : maxLines,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        // Show an icon on the left only when one is supplied.
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),

        // Used for controls such as the show/hide password button.
        suffixIcon: suffixIcon,

        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest
            .withOpacity(0.35),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

        // Rounded corners for the normal, focused, and error states.
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}
