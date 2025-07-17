import 'package:flutter/material.dart';

class CommonBottomSheet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String message;

  const CommonBottomSheet({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

void showCommonBottomSheet({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String message,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => CommonBottomSheet(
      icon: icon,
      iconColor: iconColor,
      message: message,
    ),
  );
}
