/*
 * Copyright (c)  Rafal Slosarz 2023.
 */

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:realm/realm.dart';
import 'package:shelf_master/src/l10n/l10n.dart';
import 'package:shelf_master/src/model/schema.dart';
import 'package:shelf_master/src/repo/analytics_repository.dart';
import 'package:shelf_master/src/repo/category_repository.dart';
import 'package:shelf_master/src/repo/group_repository.dart';
import 'package:shelf_master/src/repo/internal_storage_repository.dart';
import 'package:shelf_master/src/repo/item_repository.dart';
import 'package:shelf_master/src/routes.dart';
import 'package:shelf_master/src/speech/speech_service.dart';
import 'package:shelf_master/src/theme/app_theme.dart';

class ShelfMasterApp extends StatefulWidget {
  const ShelfMasterApp({
    Key? key,
  }) : super(key: key);

  @override
  State<ShelfMasterApp> createState() => _ShelfMasterAppState();
}

class _ShelfMasterAppState extends State<ShelfMasterApp> {
  late final GoRouter goRouter;

  @override
  void initState() {
    super.initState();
    goRouter = GoRouter(
      routes: $appRoutes,
      debugLogDiagnostics: kDebugMode,
      observers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: _repositoryProviders(),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            restorationScopeId: 'app',
            debugShowCheckedModeBanner: true,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (context) => context.l10n.appTitle,
            theme: AppTheme.lightThemeData,
            darkTheme: AppTheme.darkThemeData,
            themeMode: ThemeMode.light,
            routerDelegate: goRouter.routerDelegate,
            routeInformationParser: goRouter.routeInformationParser,
          );
        },
      ),
    );
  }

  List<RepositoryProvider> _repositoryProviders() {
    return [
      RepositoryProvider<Realm>(
        create: (context) => Realm(
          Configuration.local(
            [
              GroupSchema.schema,
              ItemSchema.schema,
              CategorySchema.schema,
              ParameterSchema.schema,
            ],
          ),
        ),
      ),
      RepositoryProvider<AnalyticsRepository>(
        create: (context) => AnalyticsRepository(),
      ),
      RepositoryProvider<ItemRepository>(
        create: (context) => ItemRepository(
          realm: context.read<Realm>(),
        ),
      ),
      RepositoryProvider<GroupRepository>(
        create: (context) => GroupRepository(
          realm: context.read<Realm>(),
        ),
      ),
      RepositoryProvider<CategoryRepository>(
        create: (context) => CategoryRepository(
          realm: context.read<Realm>(),
        ),
      ),
      RepositoryProvider<InternalStorageRepository>(
        create: (context) => InternalStorageRepository(
          analyticsRepository: context.read<AnalyticsRepository>(),
        ),
      ),
      RepositoryProvider<SpeechService>(
        create: (context) => SpeechService()..initSpeech(),
      ),
    ];
  }
}
