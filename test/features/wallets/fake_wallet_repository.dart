import 'dart:async';

import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/wallets/data/wallet_repository.dart';

/// In-memory fake test double for [WalletRepositoryBase] to avoid Isar async
/// hangs under `testWidgets()`.
class FakeWalletRepository implements WalletRepositoryBase {
  FakeWalletRepository({List<Wallet>? initialWallets}) {
    if (initialWallets != null) {
      _wallets.addAll(initialWallets);
      for (final w in initialWallets) {
        if (w.id >= _nextId) {
          _nextId = w.id + 1;
        }
      }
    }
  }

  final List<Wallet> _wallets = [];
  final List<db.Transaction> recordedTransactions = [];
  final _walletsController = StreamController<List<Wallet>>.broadcast();
  int _nextId = 1;

  void dispose() {
    _walletsController.close();
  }

  void _notify() {
    final sorted = [..._wallets]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _walletsController.add(sorted);
  }

  @override
  Stream<List<Wallet>> watchWallets() async* {
    final current = [..._wallets]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    yield current;
    yield* _walletsController.stream;
  }

  @override
  Future<List<Wallet>> getWallets() async {
    return [..._wallets]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<Wallet?> getWallet(int id) async {
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Wallet> saveWallet({
    int? id,
    required String name,
    required String icon,
    required int startingBalance,
    required bool includeInDailyBudget,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'Nama dompet tidak boleh kosong.',
      );
    }
    if (startingBalance < 0) {
      throw ArgumentError.value(
        startingBalance,
        'startingBalance',
        'Saldo awal tidak boleh negatif.',
      );
    }

    Wallet wallet;
    if (id != null && id > 0) {
      final idx = _wallets.indexWhere((w) => w.id == id);
      if (idx >= 0) {
        wallet = _wallets[idx];
      } else {
        wallet = Wallet()..id = id;
        _wallets.add(wallet);
      }
    } else {
      wallet = Wallet()
        ..id = _nextId++
        ..createdAt = DateTime.now();
      _wallets.add(wallet);
    }

    wallet.name = trimmed;
    wallet.icon = icon;
    wallet.startingBalance = startingBalance;
    wallet.includeInDailyBudget = includeInDailyBudget;

    _notify();
    return wallet;
  }

  @override
  Future<void> deleteWallet(int id) async {
    if (_wallets.length <= 1) {
      throw const WalletDeleteRestrictedException();
    }

    final hasTxs = recordedTransactions.any(
      (t) => t.walletId == id || t.transferPeerWalletId == id,
    );
    if (hasTxs) {
      throw const WalletHasTransactionsException();
    }

    _wallets.removeWhere((w) => w.id == id);
    _notify();
  }

  @override
  Future<db.Transaction> transfer({
    required int sourceWalletId,
    required int targetWalletId,
    required int amount,
    required DateTime date,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Nominal transfer harus lebih besar dari nol.',
      );
    }
    if (sourceWalletId <= 0 || targetWalletId <= 0) {
      throw ArgumentError('Dompet asal dan tujuan harus dipilih.');
    }
    if (sourceWalletId == targetWalletId) {
      throw ArgumentError('Dompet asal dan tujuan tidak boleh sama.');
    }

    final tx = db.Transaction()
      ..id = recordedTransactions.length + 1
      ..type = db.TransactionType.transfer
      ..amount = amount
      ..categoryId = 0
      ..walletId = sourceWalletId
      ..transferPeerWalletId = targetWalletId
      ..transferGroupId = 'trf_${DateTime.now().microsecondsSinceEpoch}'
      ..date = date
      ..notes = notes?.trim().isEmpty == true ? null : notes?.trim();

    recordedTransactions.add(tx);
    return tx;
  }
}
