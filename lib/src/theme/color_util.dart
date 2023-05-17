/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'dart:math';

import 'package:flutter/material.dart';

class ColorUtil {
  static final List<Color> colors = [
    const Color(0xFFF9DC5C),
    const Color(0xFFC2EABD),
    const Color(0xFF476080),
    const Color(0xFF465362),
    const Color(0xFF0E79B2),
    const Color(0xFFF39237),
    const Color(0xFF1E555C),
    const Color(0xFFEDB183),
    const Color(0xFF515B3A),
    const Color(0xFFDB162F),
  ];

  /// [hexString] in format of XXXXXXXX
  /// [fallback] is returned when [hexString] was not parsable to int
  static Color hexToColor(
    String hexString, {
    Color fallback = Colors.transparent,
  }) {
    final parseInt = int.tryParse('0x$hexString');
    if (parseInt == null) {
      return fallback;
    }
    return Color(parseInt);
  }

  static String getRandomHexColor() {
    return colors[Random().nextInt(10)].value.toRadixString(16);
  }
}
