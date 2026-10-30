import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_provider.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/database/wallet.dart';
import '../../transactions/application/transaction_providers.dart';
import '../data/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepositoryBase>((ref) {
  try {
    return WalletRepository(ref.watch(isarProvider));
  } on UnimplementedError {
    return _FallbackWalletRepository();
  }
});

class SelectedWalletFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? id) => state = id;
}

final selectedWalletFilterProvider =
    NotifierProvider<SelectedWalletFilterNotifier, int?>(
      SelectedWalletFilterNotifier.new,
    );

final walletsStreamProvider = StreamProvider<List<Wallet>>((ref) {
  return ref.watch(walletRepositoryProvider).watchWallets();
});

final walletsMapProvider = Provider<Map<int, Wallet>>((ref) {
  final walletsAsync = ref.watch(walletsStreamProvider);
  return walletsAsync.maybeWhen(
    data: (wallets) => {for (final w in wallets) w.id: w},
    orElse: () => const <int, Wallet>{},
  );
});

/// Computed balances for each wallet, keyed by wallet.id.
final walletBalancesProvider = Provider<AsyncValue<Map<int, int>>>((ref) {
  final walletsAsync = ref.watch(walletsStreamProvider);
  final txsAsync = ref.watch(transactionsStreamProvider);

  if (walletsAsync.hasError) {
    return AsyncValue.error(walletsAsync.error!, walletsAsync.stackTrace!);
  }
  if (txsAsync.hasError) {
    return AsyncValue.error(txsAsync.error!, txsAsync.stackTrace!);
  }

  if (walletsAsync.isLoading || txsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final wallets = walletsAsync.value ?? const [];
  final txs = txsAsync.value ?? const [];

  final map = <int, int>{};
  for (final w in wallets) {
    map[w.id] = computeWalletBalance(w, txs);
  }

  return AsyncValue.data(map);
});

/// Total Saldo (Net Worth): sum of ALL wallets regardless of [includeInDailyBudget] (FR-12, D16).
final totalSaldoProvider = Provider<AsyncValue<int>>((ref) {
  final balancesAsync = ref.watch(walletBalancesProvider);
  return balancesAsync.whenData((map) {
    return map.values.fold<int>(0, (sum, balance) => sum + balance);
  });
});

class WalletFormState {
  const WalletFormState({
    this.name = '',
    this.icon = 'account_balance_wallet',
    this.startingBalance = 0,
    this.includeInDailyBudget = true,
    this.isSubmitting = false,
    this.submitError,
    this.initialWalletId,
  });

  final String name;
  final String icon;
  final int startingBalance;
  final bool includeInDailyBudget;
  final bool isSubmitting;
  final String? submitError;
  final int? initialWalletId;

  bool get isEditMode => initialWalletId != null;
  bool get isValid => name.trim().isNotEmpty && startingBalance >= 0;

  WalletFormState copyWith({
    String? name,
    String? icon,
    int? startingBalance,
    bool? includeInDailyBudget,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    int? initialWalletId,
  }) {
    return WalletFormState(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      startingBalance: startingBalance ?? this.startingBalance,
      includeInDailyBudget: includeInDailyBudget ?? this.includeInDailyBudget,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      initialWalletId: initialWalletId ?? this.initialWalletId,
    );
  }
}

class WalletFormNotifier extends Notifier<WalletFormState> {
  @override
  WalletFormState build() => const WalletFormState();

  void init(Wallet? wallet) {
    if (wallet != null) {
      state = WalletFormState(
        name: wallet.name,
        icon: wallet.icon,
        startingBalance: wallet.startingBalance,
        includeInDailyBudget: wallet.includeInDailyBudget,
        initialWalletId: wallet.id,
      );
    } else {
      state = const WalletFormState();
    }
  }

  void setName(String name) {
    state = state.copyWith(name: name, clearSubmitError: true);
  }

  void setIcon(String icon) {
    state = state.copyWith(icon: icon);
  }

  void setStartingBalance(int amount) {
    state = state.copyWith(startingBalance: amount, clearSubmitError: true);
  }

  void setIncludeInDailyBudget(bool value) {
    state = state.copyWith(includeInDailyBudget: value);
  }

  /// D18/M17 bug #8: re-entrancy guard, same pattern as
  /// `pay_cycle_providers.dart`'s `submitTransition`.
  Future<bool> save() async {
    if (state.isSubmitting) return false;
    if (!state.isValid) {
      state = state.copyWith(submitError: 'Nama dompet tidak boleh kosong.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);
    try {
      await ref
          .read(walletRepositoryProvider)
          .saveWallet(
            id: state.initialWalletId,
            name: state.name,
            icon: state.icon,
            startingBalance: state.startingBalance,
            includeInDailyBudget: state.includeInDailyBudget,
          );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submitError: e.toString());
      return false;
    }
  }
}

final walletFormProvider =
    NotifierProvider<WalletFormNotifier, WalletFormState>(
      WalletFormNotifier.new,
    );

class _FallbackWalletRepository implements WalletRepositoryBase {
  final List<Wallet> _wallets = [
    Wallet()
      ..id = 1
      ..name = defaultWalletName
      ..icon = defaultWalletIcon
      ..startingBalance = 0
      ..includeInDailyBudget = true
      ..createdAt = DateTime.now(),
  ];

  @override
  Stream<List<Wallet>> watchWallets() =>
      Stream.value(List.unmodifiable(_wallets));

  @override
  Future<List<Wallet>> getWallets() async => List.unmodifiable(_wallets);

  @override
  Future<Wallet?> getWallet(int id) async {
    return _wallets.where((w) => w.id == id).firstOrNull;
  }

  @override
  Future<Wallet> saveWallet({
    int? id,
    required String name,
    required String icon,
    required int startingBalance,
    required bool includeInDailyBudget,
  }) async {
    final w = (id != null ? await getWallet(id) : null) ?? Wallet();
    if (id != null) {
      w.id = id;
    } else {
      w.id = _wallets.length + 1;
    }
    w.name = name;
    w.icon = icon;
    w.startingBalance = startingBalance;
    w.includeInDailyBudget = includeInDailyBudget;
    if (!_wallets.any((x) => x.id == w.id)) {
      _wallets.add(w);
    }
    return w;
  }

  @override
  Future<void> deleteWallet(int id) async {
    _wallets.removeWhere((w) => w.id == id);
  }

  @override
  Future<db.Transaction> transfer({
    required int sourceWalletId,
    required int targetWalletId,
    required int amount,
    required DateTime date,
    String? notes,
  }) async {
    return db.Transaction()
      ..type = db.TransactionType.transfer
      ..amount = amount
      ..categoryId = 0
      ..walletId = sourceWalletId
      ..transferPeerWalletId = targetWalletId
      ..date = date
      ..notes = notes;
  }
}
