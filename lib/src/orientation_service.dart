/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/services.dart';

class OrientationService {
  static Future<void> setOrientation(DeviceOrientation orientation) async {
    await SystemChrome.setPreferredOrientations([orientation]);
  }

  static Future<void> resetOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
