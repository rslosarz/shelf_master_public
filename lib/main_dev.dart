/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'dart:async';

import 'init.dart';
import 'src/flavor/flavor.dart';

Future<void> main() async {
  return commonMain(Flavor.dev);
}
