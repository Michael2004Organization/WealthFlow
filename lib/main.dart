import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/wealthflow_app.dart';
import 'core/database/app_database.dart';
import 'core/providers.dart';

void main() {
  AppDatabase? database;
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      database = AppDatabase();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        unawaited(
          database?.logError(
            source: 'Flutter',
            error: details.exception,
            stackTrace: details.stack,
            details: details.context?.toDescription() ?? '',
          ),
        );
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(
          database?.logError(
            source: 'Platform',
            error: error,
            stackTrace: stack,
          ),
        );
        return true;
      };
      runApp(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database!)],
          child: const WealthFlowApp(),
        ),
      );
    },
    (error, stack) {
      unawaited(
        database?.logError(source: 'Zone', error: error, stackTrace: stack),
      );
    },
  );
}
