// Regression test for D18/M17 bug #1: `tz.setLocalLocation` was never
// called, so `tz.local` silently defaulted to UTC and every scheduled
// notification fired at the wrong wall-clock time for any non-UTC device
// (e.g. 21:00 WIB appearing to fire at 04:00). `configureLocalTimezone`
// takes an injectable `resolveTimezoneName` so this is testable without the
// `flutter_timezone` platform channel (unavailable under `flutter test`).
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/features/notifications/data/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('configureLocalTimezone (D18/M17 bug #1)', () {
    test('sets tz.local to the resolved device timezone, not UTC', () async {
      await configureLocalTimezone(
        resolveTimezoneName: () async => 'Asia/Jakarta',
      );

      expect(tz.local.name, 'Asia/Jakarta');
      expect(tz.local.name, isNot('UTC'));

      // WIB is UTC+7 with no daylight saving — a 21:00 local time must be
      // 7 hours behind in UTC terms, confirming the offset is really wired
      // through (not just that a string got stored somewhere).
      final localNine = tz.TZDateTime(tz.local, 2026, 6, 1, 21, 0);
      final asUtc = localNine.toUtc();
      expect(asUtc.hour, 14); // 21:00 WIB == 14:00 UTC
    });

    test('falls back gracefully (no throw) when the resolver fails, e.g. '
        'the flutter_timezone plugin channel is unavailable', () async {
      await expectLater(
        configureLocalTimezone(
          resolveTimezoneName: () async =>
              throw Exception('platform channel unavailable'),
        ),
        completes,
      );
    });

    test('falls back gracefully when the resolved name is not a known '
        'timezone identifier', () async {
      await expectLater(
        configureLocalTimezone(resolveTimezoneName: () async => 'Not/AZone'),
        completes,
      );
    });
  });
}
