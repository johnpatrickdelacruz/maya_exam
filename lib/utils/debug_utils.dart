import 'package:flutter/foundation.dart';

/// Debug utility class for conditional printing based on debug mode
class DebugUtils {
  static void debugPrint(String message, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final formattedMessage = tag != null
          ? '[$timestamp] [DEBUG] [$tag] $message'
          : '[$timestamp] [DEBUG] $message';
      print(formattedMessage);
    }
  }

  static void errorPrint(String message, {String? tag}) {
    final timestamp = DateTime.now().toIso8601String();
    final formattedMessage = tag != null
        ? '[$timestamp] [ERROR] [$tag] $message'
        : '[$timestamp] [ERROR] $message';
    if (kDebugMode) {
      print(formattedMessage);
    }
  }
}
