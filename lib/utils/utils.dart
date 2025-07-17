import 'package:flutter/material.dart';
import 'package:new_maya_exam/widget/dialog/common_dialog.dart';

class Utils {
  static Future<void> showCommonDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String cancelText,
    required String okText,
    required VoidCallback onCancel,
    required VoidCallback onOk,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CommonDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        okText: okText,
        onCancel: onCancel,
        onOk: onOk,
      ),
    );
  }
}
