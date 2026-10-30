// Regression test for D18/M17 bug #6: the app registered no global error
// handler at all — any uncaught Flutter framework or platform/async error
// fell through to Flutter's default behavior with no app-level logging or
// recovery hook. `installGlobalErrorHandlers` wires both surfaces.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/error/global_error_handler.dart';

void main() {
  FlutterExceptionHandler? originalFlutterOnError;
  dynamic originalPlatformOnError;

  setUp(() {
    originalFlutterOnError = FlutterError.onError;
    originalPlatformOnError = PlatformDispatcher.instance.onError;
  });

  tearDown(() {
    FlutterError.onError = originalFlutterOnError;
    PlatformDispatcher.instance.onError = originalPlatformOnError;
  });

  test('installs a FlutterError.onError handler that does not rethrow', () {
    installGlobalErrorHandlers();

    expect(FlutterError.onError, isNotNull);
    expect(
      () => FlutterError.onError!(
        FlutterErrorDetails(exception: Exception('boom')),
      ),
      returnsNormally,
    );
  });

  test('installs a PlatformDispatcher.onError handler that returns true '
      '(marks the error handled instead of crashing the isolate)', () {
    installGlobalErrorHandlers();

    expect(PlatformDispatcher.instance.onError, isNotNull);
    final handled = PlatformDispatcher.instance.onError!(
      Exception('async boom'),
      StackTrace.empty,
    );
    expect(handled, isTrue);
  });

  test('custom onFlutterError/onPlatformError callbacks are invoked', () {
    FlutterErrorDetails? capturedDetails;
    Object? capturedError;

    installGlobalErrorHandlers(
      onFlutterError: (details) => capturedDetails = details,
      onPlatformError: (error, stack) {
        capturedError = error;
        return true;
      },
    );

    FlutterError.onError!(FlutterErrorDetails(exception: Exception('x')));
    expect(capturedDetails, isNotNull);

    PlatformDispatcher.instance.onError!(Exception('y'), StackTrace.empty);
    expect(capturedError, isNotNull);
  });
}
