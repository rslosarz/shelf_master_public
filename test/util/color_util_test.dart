import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_master/src/theme/color_util.dart';

void main() {
  group('color util', () {
    final inputsToExpected = {
      'FFFFFFFF': const Color(0xFFFFFFFF),
      'FFC2AFA1': const Color(0xFFC2AFA1),
      'FFBB5D38': const Color(0xFFBB5D38),
      'FFE5E5E5': const Color(0xFFE5E5E5),
      // ignore: use_full_hex_values_for_flutter_colors
      '3748921': const Color(0x3748921),
      'asdasda': Colors.transparent,
      '': Colors.transparent,
      'FFzxcjd': Colors.transparent,
    };
    inputsToExpected.forEach((input, expected) {
      test('$input -> $expected', () {
        expect(ColorUtil.hexToColor(input), expected);
      });
    });
  });

  group('color util default', () {
    final inputsToExpected = {
      const Color(0xFF000000): const Color(0xFF000000),
      const Color(0xFFC2AFA1): const Color(0xFFC2AFA1),
    };
    inputsToExpected.forEach((input, expected) {
      test('$input -> $expected', () {
        expect(ColorUtil.hexToColor('0xsdjhadska', fallback: input), expected);
      });
    });
  });
}
