// Regression test for D18/M17 bug #8: save buttons had no re-entrancy
// guard — a double-tap before the UI rebuilds to show `isSubmitting` could
// race through `save()`/`delete()` twice and write duplicate records.
// `TransactionFormNotifier.save()`/`delete()` now check `state.isSubmitting`
// synchronously as the very first line, which this test exercises by
// firing two concurrent calls without awaiting the first (simulating two
// taps landing in the same frame, before Riverpod's state change has had a
// chance to propagate to a rebuilt, disabled button).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/transactions/application/transaction_providers.dart';

import 'fake_transaction_repository.dart';

void main() {
  late ProviderContainer container;
  late FakeTransactionRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeTransactionRepository();
    container = ProviderContainer(
      overrides: [transactionRepositoryProvider.overrideWithValue(fakeRepo)],
    );
  });

  tearDown(() {
    container.dispose();
    fakeRepo.dispose();
  });

  test('double-tapping save() before the first call resolves only writes '
      'the transaction once', () async {
    final notifier = container.read(transactionFormProvider.notifier);
    notifier.setAmount(50000);
    notifier.setCategory(1);
    notifier.setWallet(1);

    // Two "taps" fired back-to-back without awaiting the first — this is
    // exactly the race a fast double-tap produces before Riverpod's
    // `isSubmitting: true` state change reaches a rebuilt UI frame.
    final first = notifier.save();
    final second = notifier.save();

    final results = await Future.wait([first, second]);

    expect(fakeRepo.savedCalls.length, 1);
    // Exactly one of the two calls should report success; the other must
    // have bailed out via the guard (returning false), not silently
    // failed or silently duplicated.
    expect(results.where((r) => r).length, 1);
  });

  test('double-tapping delete() before the first call resolves only deletes '
      'once', () async {
    final tx = await fakeRepo.saveTransaction(
      type: db.TransactionType.expense,
      amount: 10000,
      categoryId: 1,
      date: DateTime.now(),
      walletId: 1,
    );

    final notifier = container.read(transactionFormProvider.notifier);
    notifier.init(tx);

    final first = notifier.delete();
    final second = notifier.delete();

    await Future.wait([first, second]);

    expect(fakeRepo.deletedIds.length, 1);
  });
}
