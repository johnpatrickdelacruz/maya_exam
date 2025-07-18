import 'package:flutter/material.dart';
import 'package:new_maya_exam/widget/common/common_app_text.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: color,
      ),
      child: AppText.labelLarge(text),
    );
  }
}
