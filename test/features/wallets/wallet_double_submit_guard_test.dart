// Regression test for D18/M17 bug #8, wallet form variant — see
// `test/features/transactions/transaction_double_submit_guard_test.dart`
// for the full rationale. `WalletFormNotifier.save()` now checks
// `state.isSubmitting` synchronously as its first line.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/features/wallets/application/wallet_providers.dart';

import 'fake_wallet_repository.dart';

void main() {
  late ProviderContainer container;
  late FakeWalletRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeWalletRepository();
    container = ProviderContainer(
      overrides: [walletRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    // M18: walletFormProvider is now `.autoDispose` (item 6) — keep it
    // alive across this container's lifetime the same way a mounted
    // WalletFormScreen's `ref.watch` would in production.
    container.listen(walletFormProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
    fakeRepo.dispose();
  });

  test('double-tapping save() before the first call resolves only creates '
      'the wallet once', () async {
    final notifier = container.read(walletFormProvider.notifier);
    notifier.setName('Dompet Baru');
    notifier.setStartingBalance(100000);

    final first = notifier.save();
    final second = notifier.save();

    final results = await Future.wait([first, second]);

    final wallets = await fakeRepo.getWallets();
    expect(wallets.length, 1);
    expect(results.where((r) => r).length, 1);
  });
}
