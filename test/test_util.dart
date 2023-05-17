import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recase/recase.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/theme/app_theme.dart';

// ignore: depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

extension GoldenTestWidgetTesterExtension on WidgetTester {
  Future<void> multiScreenGoldenTest({
    String? name,
    Finder? finder,
    bool? autoHeight,
    double? overrideGoldenHeight,
    CustomPump? customPump,
    DeviceSetup? deviceSetup,
    List<Device>? devices,
  }) {
    final testName = Invoker.current!.liveTest.test.name;
    final generatedName = testName.snakeCase;
    return multiScreenGolden(
      this,
      name ?? generatedName,
      finder: finder,
      autoHeight: autoHeight,
      overrideGoldenHeight: overrideGoldenHeight,
      customPump: customPump,
      deviceSetup: deviceSetup,
      devices: devices,
    );
  }
}

Future<void> pumpAppWidget(
  WidgetTester tester,
  Widget widget, {
  WidgetWrapper? wrapper,
  Size? surfaceSize,
  double textScaleSize = 1.0,
}) {
  return tester.pumpWidgetBuilder(
    widget,
    wrapper: materialAppWrapper(
      localizations: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightThemeData,
    ),
  );
}

void whenBloc<State>(
  BlocBase<State> bloc,
  Stream<State> stream, {
  State? initialState,
}) {
  final broadcastStream = stream.asBroadcastStream();

  if (initialState != null) {
    when(() => bloc.state).thenReturn(initialState);
  }

  when(() => bloc.stream).thenAnswer(
    (_) => broadcastStream.map((state) {
      when(() => bloc.state).thenReturn(state);
      return state;
    }),
  );

  when(() => bloc.close()).thenAnswer((invocation) => Future.value());
}
