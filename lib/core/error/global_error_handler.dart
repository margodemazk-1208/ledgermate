// D18/M17 bug #6: `main.dart` opened Isar and ran the M12 migration with no
// try/catch, and the app registered no global error handler at all — any
// uncaught error during boot (corrupted DB file, interrupted write, a bug
// in a widget's `build()`) fell straight through to Flutter's default
// behavior, which on a release build is a silent blank/grey screen with no
// explanation and no recovery path for the user.
//
// [installGlobalErrorHandlers] wires both error surfaces Flutter exposes:
// - `FlutterError.onError` — synchronous errors thrown during the
//   widget/render pipeline (build/layout/paint).
// - `PlatformDispatcher.instance.onError` — everything else (async errors
//   outside a `Zone.onError`, platform channel errors, etc).
//
// Neither handler can "fix" the error; the point is to make sure it is
// logged instead of silently swallowed, and that returning `true` from the
// `PlatformDispatcher` handler stops Flutter from also forwarding it to the
// default fatal-error path that blanks the screen with no app-level UI at
// all. Catastrophic BOOT failures (e.g. `Isar.open` itself throwing) are
// handled separately in `main.dart` via [DatabaseErrorScreen] — that one
// needs a full replacement UI, not just logging, since there is no widget
// tree yet to show an in-app error banner in.
import 'package:flutter/foundation.dart';

/// Installs app-wide handlers for uncaught Flutter framework and platform
/// errors so they are logged instead of silently dropped. Safe to call
/// multiple times (each call simply overwrites the previous handler with an
/// equivalent one) — idempotent for repeated app boots in tests.
void installGlobalErrorHandlers({
  void Function(FlutterErrorDetails details)? onFlutterError,
  bool Function(Object error, StackTrace stack)? onPlatformError,
}) {
  final previousFlutterOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint(
      'Uncaught Flutter framework error: ${details.exceptionAsString()}',
    );
    if (onFlutterError != null) {
      onFlutterError(details);
    } else {
      // Preserve the previous behavior (red screen in debug, framework log
      // in release) IN ADDITION to our own logging above — we augment,
      // never silently replace, Flutter's own diagnostics.
      previousFlutterOnError?.call(details);
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught platform/async error: $error\n$stack');
    if (onPlatformError != null) {
      return onPlatformError(error, stack);
    }
    // Returning true marks the error "handled" so Flutter does not also
    // crash the isolate / show its own unhandled-error path on top of ours.
    return true;
  };
}
