import 'package:flutter/material.dart';

class AppFont {
  AppFont._();

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Base text styles for HRM app
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: bold,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: bold,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.4,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    height: 1.4,
  );

  // Special styles for HRM app
  static const TextStyle employeeId = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.5,
  );

  static const TextStyle salary = TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
  );

  static const TextStyle status = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: regular,
    height: 1.3,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.2,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: semiBold,
    letterSpacing: 0.1,
  );

  static const TextStyle tabLabel = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.4,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    height: 1.4,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.3,
  );
}

extension AppFontSize on TextStyle {
  // Font sizes
  TextStyle get s10 {
    return copyWith(fontSize: 10);
  }

  TextStyle get s12 {
    return copyWith(fontSize: 12);
  }

  TextStyle get s14 {
    return copyWith(fontSize: 14);
  }

  TextStyle get s16 {
    return copyWith(fontSize: 16);
  }

  TextStyle get s18 {
    return copyWith(fontSize: 18);
  }

  TextStyle get s20 {
    return copyWith(fontSize: 20);
  }

  TextStyle get s24 {
    return copyWith(fontSize: 24);
  }

  TextStyle get s28 {
    return copyWith(fontSize: 28);
  }

  TextStyle get s32 {
    return copyWith(fontSize: 32);
  }
}

extension AppFontWeight on TextStyle {
  // Font weights
  TextStyle get light {
    return copyWith(fontWeight: AppFont.light);
  }

  TextStyle get regular {
    return copyWith(fontWeight: AppFont.regular);
  }

  TextStyle get medium {
    return copyWith(fontWeight: AppFont.medium);
  }

  TextStyle get semiBold {
    return copyWith(fontWeight: AppFont.semiBold);
  }

  TextStyle get bold {
    return copyWith(fontWeight: AppFont.bold);
  }

  TextStyle get extraBold {
    return copyWith(fontWeight: AppFont.extraBold);
  }
}

extension AppFontSpacing on TextStyle {
  // Letter spacing
  TextStyle get tightSpacing {
    return copyWith(letterSpacing: -0.5);
  }

  TextStyle get normalSpacing {
    return copyWith(letterSpacing: 0);
  }

  TextStyle get wideSpacing {
    return copyWith(letterSpacing: 0.5);
  }

  TextStyle get extraWideSpacing {
    return copyWith(letterSpacing: 1.0);
  }
}

extension AppFontHeight on TextStyle {
  // Line height
  TextStyle get tightHeight {
    return copyWith(height: 1.2);
  }

  TextStyle get normalHeight {
    return copyWith(height: 1.4);
  }

  TextStyle get relaxedHeight {
    return copyWith(height: 1.6);
  }
}
