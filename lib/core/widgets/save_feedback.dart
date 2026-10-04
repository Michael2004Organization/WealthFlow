import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Runs [action] after a dialog has closed and tells the user when it
/// fails, so an input is never lost without a word. Returns whether the
/// action succeeded.
Future<bool> saveWithFeedback(
  BuildContext context,
  Future<void> Function() action, {
  String failure = 'Speichern fehlgeschlagen',
  String source = 'Speichern',
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  ProviderContainer? container;
  try {
    container = ProviderScope.containerOf(context, listen: false);
  } catch (_) {
    container = null;
  }
  try {
    await action();
    return true;
  } catch (error, stackTrace) {
    debugPrint('$failure: $error');
    await container
        ?.read(databaseProvider)
        .logError(
          userId: container.read(currentUserIdProvider),
          source: source,
          error: error,
          stackTrace: stackTrace,
        );
    messenger?.showSnackBar(
      SnackBar(content: Text(saveErrorMessage(error, failure))),
    );
    return false;
  }
}

/// German text for a failed save. Errors the app raises on purpose
/// ([StateError], [ArgumentError]) already carry a readable reason;
/// anything else gets a generic hint instead of a technical message.
String saveErrorMessage(Object error, String failure) {
  final reason = switch (error) {
    StateError(:final message) => message,
    ArgumentError(:final message) when message is String => message,
    _ => '',
  };
  return reason.trim().isEmpty
      ? '$failure. Bitte erneut versuchen.'
      : '$failure: ${reason.trim()}';
}
