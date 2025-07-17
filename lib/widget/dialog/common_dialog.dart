import 'package:flutter/material.dart';

class CommonDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String okText;
  final VoidCallback onCancel;
  final VoidCallback onOk;

  const CommonDialog({
    super.key,
    required this.title,
    required this.content,
    required this.cancelText,
    required this.okText,
    required this.onCancel,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: onOk,
          child: Text(okText),
        ),
      ],
    );
  }
}
