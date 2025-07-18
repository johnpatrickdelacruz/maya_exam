import 'package:flutter/material.dart';
import 'dart:ui' show FontFeature;

/// A reusable text widget that provides consistent styling throughout the app
class AppText extends StatelessWidget {
  final String text;
  final AppTextStyle style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final double? height;
  final double? letterSpacing;
  final TextDecoration? decoration;

  const AppText(
    this.text, {
    super.key,
    this.style = AppTextStyle.body,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  });

  // Named constructors for common text styles
  const AppText.displayLarge(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.displayLarge,
        fontSize = null,
        fontWeight = null;

  const AppText.displayMedium(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.displayMedium,
        fontSize = null,
        fontWeight = null;

  const AppText.displaySmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.displaySmall,
        fontSize = null,
        fontWeight = null;

  const AppText.headlineLarge(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.headlineLarge,
        fontSize = null,
        fontWeight = null;

  const AppText.headlineMedium(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.headlineMedium,
        fontSize = null,
        fontWeight = null;

  const AppText.headlineSmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.headlineSmall,
        fontSize = null,
        fontWeight = null;

  const AppText.titleLarge(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.titleLarge,
        fontSize = null,
        fontWeight = null;

  const AppText.titleMedium(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.titleMedium,
        fontSize = null,
        fontWeight = null;

  const AppText.titleSmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.titleSmall,
        fontSize = null,
        fontWeight = null;

  const AppText.bodyLarge(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.bodyLarge,
        fontSize = null,
        fontWeight = null;

  const AppText.bodyMedium(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.bodyMedium,
        fontSize = null,
        fontWeight = null;

  const AppText.body(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.body,
        fontSize = null,
        fontWeight = null;

  const AppText.bodySmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.bodySmall,
        fontSize = null,
        fontWeight = null;

  const AppText.labelLarge(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.labelLarge,
        fontSize = null,
        fontWeight = null;

  const AppText.labelMedium(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.labelMedium,
        fontSize = null,
        fontWeight = null;

  const AppText.labelSmall(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.labelSmall,
        fontSize = null,
        fontWeight = null;

  // Special styled constructors
  const AppText.currency(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.currency,
        fontSize = null,
        fontWeight = null;

  const AppText.error(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.error,
        color = null,
        fontSize = null,
        fontWeight = null;

  const AppText.success(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.success,
        color = null,
        fontSize = null,
        fontWeight = null;

  const AppText.warning(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.warning,
        color = null,
        fontSize = null,
        fontWeight = null;

  const AppText.hint(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
    this.decoration,
  })  : style = AppTextStyle.hint,
        color = null,
        fontSize = null,
        fontWeight = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    TextStyle baseStyle = _getBaseStyle(textTheme);

    // Apply custom overrides
    final customStyle = baseStyle.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );

    return Text(
      text,
      style: customStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  TextStyle _getBaseStyle(TextTheme textTheme) {
    switch (style) {
      case AppTextStyle.displayLarge:
        return textTheme.displayLarge ??
            const TextStyle(fontSize: 57, fontWeight: FontWeight.w400);
      case AppTextStyle.displayMedium:
        return textTheme.displayMedium ??
            const TextStyle(fontSize: 45, fontWeight: FontWeight.w400);
      case AppTextStyle.displaySmall:
        return textTheme.displaySmall ??
            const TextStyle(fontSize: 36, fontWeight: FontWeight.w400);
      case AppTextStyle.headlineLarge:
        return textTheme.headlineLarge ??
            const TextStyle(fontSize: 32, fontWeight: FontWeight.w400);
      case AppTextStyle.headlineMedium:
        return textTheme.headlineMedium ??
            const TextStyle(fontSize: 28, fontWeight: FontWeight.w400);
      case AppTextStyle.headlineSmall:
        return textTheme.headlineSmall ??
            const TextStyle(fontSize: 24, fontWeight: FontWeight.w400);
      case AppTextStyle.titleLarge:
        return textTheme.titleLarge ??
            const TextStyle(fontSize: 22, fontWeight: FontWeight.w400);
      case AppTextStyle.titleMedium:
        return textTheme.titleMedium ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
      case AppTextStyle.titleSmall:
        return textTheme.titleSmall ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
      case AppTextStyle.bodyLarge:
        return textTheme.bodyLarge ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
      case AppTextStyle.bodyMedium:
      case AppTextStyle.body:
        return textTheme.bodyMedium ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
      case AppTextStyle.bodySmall:
        return textTheme.bodySmall ??
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
      case AppTextStyle.labelLarge:
        return textTheme.labelLarge ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
      case AppTextStyle.labelMedium:
        return textTheme.labelMedium ??
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
      case AppTextStyle.labelSmall:
        return textTheme.labelSmall ??
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
      case AppTextStyle.currency:
        return const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()]);
      case AppTextStyle.error:
        return textTheme.bodyMedium?.copyWith(color: Colors.red) ??
            const TextStyle(fontSize: 14, color: Colors.red);
      case AppTextStyle.success:
        return textTheme.bodyMedium?.copyWith(color: Colors.green) ??
            const TextStyle(fontSize: 14, color: Colors.green);
      case AppTextStyle.warning:
        return textTheme.bodyMedium?.copyWith(color: Colors.orange) ??
            const TextStyle(fontSize: 14, color: Colors.orange);
      case AppTextStyle.hint:
        return textTheme.bodySmall?.copyWith(color: Colors.grey) ??
            const TextStyle(fontSize: 12, color: Colors.grey);
    }
  }
}

/// Enumeration of available text styles
enum AppTextStyle {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  body,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  currency,
  error,
  success,
  warning,
  hint,
}
