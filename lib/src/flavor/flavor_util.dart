/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:flutter/material.dart';

import 'flavor.dart';

class FlavorUtil {
  static void init(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        FlavorConfig(
          name: flavor.name,
          color: Colors.red,
          variables: {
            'isDeveloper': true,
            'logging': true,
          },
        );
        break;
      case Flavor.prod:
        FlavorConfig(
          name: flavor.name,
          color: Colors.black,
          variables: {
            'isDeveloper': false,
            'logging': false,
          },
        );
        break;
    }
  }

  const FlavorUtil._();
}

extension FlavorConfigExtensions on FlavorConfig {
  bool get isDeveloper => variables['isDeveloper'] as bool;

  bool get logging => variables['logging'] as bool;
}
