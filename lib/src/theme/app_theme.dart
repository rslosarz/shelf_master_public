/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';

class AppTheme {
  static const fontColor = Color(0xff01041a);
  static const inactive = Color(0xffd9d9d9);
  static const primary = Color(0xff3ec42a);
  static const delete = Color(0xFFFE4A49);

  static final lightThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Ubuntu',
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: primary,
      primary: primary,
      background: const Color(0xfff5f6f6),
      surface: const Color(0xffffffff),
      surfaceTint: const Color(0xffffffff),
    ),
  );
  static final darkThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Ubuntu',
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: primary,
      primary: primary,
      background: const Color(0xff707070),
      surface: const Color(0xff262626),
      surfaceTint: const Color(0xff262626),
    ),
  );

  static const boxShadow = [
    BoxShadow(
      color: Colors.black,
      blurRadius: 2.0,
      spreadRadius: 0.0,
      offset: Offset(0.0, 2.0), // shadow direction: bottom right
    ),
  ];
}
