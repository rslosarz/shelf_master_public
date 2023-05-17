/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shelf_master/src/orientation_service.dart';
import 'package:shelf_master/src/shelf_master_app.dart';

import 'src/flavor/flavor.dart';

Future<void> commonMain(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await OrientationService.setOrientation(DeviceOrientation.portraitUp);
  FlavorUtil.init(flavor);

  await _initFirebaseCrashlytics();

  await _setupErrorLogging(flavor);

  runZonedGuarded(
    () => runApp(const ShelfMasterApp()),
    FlavorConfig.instance.logging
        ? (error, stackTrace) {
            FirebaseCrashlytics.instance.recordError(error, stackTrace);
            log(error.toString(), stackTrace: stackTrace);
          }
        : (_, __) {},
  );
}

Future<void> _setupErrorLogging(Flavor flavor) async {
  final logging = FlavorConfig.instance.logging;

  if (logging) {
    FlutterError.onError = logging
        ? (details) {
            log(details.exceptionAsString(), stackTrace: details.stack);
            FirebaseCrashlytics.instance.recordFlutterError(details);
          }
        : (_) {};

    Isolate.current.addErrorListener(
      // ignore: avoid_types_on_closure_parameters
      RawReceivePort((List<dynamic> pair) async {
        final errorAndStacktrace = pair;
        await FirebaseCrashlytics.instance.recordError(
          errorAndStacktrace.first,
          errorAndStacktrace.last as StackTrace,
        );
      }).sendPort,
    );
  }
}

Future<void> _initFirebaseCrashlytics() async {
  await Firebase.initializeApp();
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(FlavorConfig.instance.logging && !kDebugMode);
}
