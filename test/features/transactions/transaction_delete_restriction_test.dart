import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/features/transactions/data/transaction_repository.dart';

void main() {
  group('FR-03 delete restriction logic (isTransactionDeletable)', () {
    final referenceToday = DateTime(2026, 10, 28, 14, 30, 0);

    test('returns true when transaction is dated today (exact same time)', () {
      final txDate = DateTime(2026, 10, 28, 14, 30, 0);
      expect(isTransactionDeletable(txDate, referenceToday), isTrue);
    });

    test(
      'returns true when transaction is dated today earlier in the morning',
      () {
        final txDate = DateTime(2026, 10, 28, 7, 15, 0);
        expect(isTransactionDeletable(txDate, referenceToday), isTrue);
      },
    );

    test('returns true when transaction is at start of today (00:00:00)', () {
      final txDate = DateTime(2026, 10, 28, 0, 0, 0);
      expect(isTransactionDeletable(txDate, referenceToday), isTrue);
    });

    test('returns true when transaction is at end of today (23:59:59)', () {
      final txDate = DateTime(2026, 10, 28, 23, 59, 59);
      expect(isTransactionDeletable(txDate, referenceToday), isTrue);
    });

    test('returns false when transaction is from yesterday', () {
      final yesterday = DateTime(2026, 10, 27, 23, 59, 59);
      expect(isTransactionDeletable(yesterday, referenceToday), isFalse);
    });

    test('returns false when transaction is from last week', () {
      final lastWeek = DateTime(2026, 10, 21, 12, 0, 0);
      expect(isTransactionDeletable(lastWeek, referenceToday), isFalse);
    });

    test('returns false when transaction is from previous month', () {
      final lastMonth = DateTime(2026, 9, 28, 12, 0, 0);
      expect(isTransactionDeletable(lastMonth, referenceToday), isFalse);
    });

    test('returns false when transaction is from previous year', () {
      final lastYear = DateTime(2025, 10, 28, 12, 0, 0);
      expect(isTransactionDeletable(lastYear, referenceToday), isFalse);
    });

    test('returns false when transaction is in the future (tomorrow)', () {
      final tomorrow = DateTime(2026, 10, 29, 9, 0, 0);
      expect(isTransactionDeletable(tomorrow, referenceToday), isFalse);
    });

    test('defaults to DateTime.now() if referenceNow is omitted', () {
      final now = DateTime.now();
      final todayTx = DateTime(now.year, now.month, now.day, 10, 0);
      final oldTx = now.subtract(const Duration(days: 2));
      expect(isTransactionDeletable(todayTx), isTrue);
      expect(isTransactionDeletable(oldTx), isFalse);
    });

    test('TransactionDeleteRestrictedException carries clear message referencing FR-03', () {
      const ex = TransactionDeleteRestrictedException();
      expect(ex.message, contains('FR-03'));
      expect(ex.message, contains('hari ini'));
      expect(ex.toString(), contains('FR-03'));
    });
  });
}
