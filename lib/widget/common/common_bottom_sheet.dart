import 'package:flutter/material.dart';
import 'package:new_maya_exam/widget/common/common_app_text.dart';

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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 48),
            const SizedBox(height: 16),
            AppText.bodyLarge(
              message,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface,
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
