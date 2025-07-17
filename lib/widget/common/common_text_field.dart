import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CommonTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}
