import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final void Function(String)? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
