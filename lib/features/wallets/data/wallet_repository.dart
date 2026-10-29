import 'package:isar_community/isar.dart';

import '../../../core/database/transaction.dart' as db;
import '../../../core/database/wallet.dart';

/// Thrown when attempting to delete a wallet with existing transactions (FR-12).
class WalletHasTransactionsException implements Exception {
  const WalletHasTransactionsException([
    this.message =
        'Dompet tidak dapat dihapus karena masih memiliki transaksi terkait. '
        'Pindahkan atau hapus transaksi terlebih dahulu (FR-12).',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when attempting to delete the last remaining wallet (FR-12).
class WalletDeleteRestrictedException implements Exception {
  const WalletDeleteRestrictedException([
    this.message = 'Minimal harus ada 1 dompet aktif di aplikasi (FR-12).',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Computes the current balance of a [Wallet] on-the-fly (FR-12, D16):
/// `startingBalance + sum(income) - sum(expense) - sum(outgoing transfer) + sum(incoming transfer)`
int computeWalletBalance(Wallet wallet, List<db.Transaction> transactions) {
  var balance = wallet.startingBalance;
  for (final tx in transactions) {
    if (tx.walletId == wallet.id) {
      if (tx.type == db.TransactionType.income) {
        balance += tx.amount;
      } else if (tx.type == db.TransactionType.expense) {
        balance -= tx.amount;
      } else if (tx.type == db.TransactionType.transfer) {
        balance -= tx.amount;
      }
    } else if (tx.transferPeerWalletId == wallet.id &&
        tx.type == db.TransactionType.transfer) {
      balance += tx.amount;
    }
  }
  return balance;
}

abstract class WalletRepositoryBase {
  Stream<List<Wallet>> watchWallets();
  Future<List<Wallet>> getWallets();
  Future<Wallet?> getWallet(int id);
  Future<Wallet> saveWallet({
    int? id,
    required String name,
    required String icon,
    required int startingBalance,
    required bool includeInDailyBudget,
  });
  Future<void> deleteWallet(int id);
  Future<db.Transaction> transfer({
    required int sourceWalletId,
    required int targetWalletId,
    required int amount,
    required DateTime date,
    String? notes,
  });
}

class WalletRepository implements WalletRepositoryBase {
  WalletRepository(this._isar);

  final Isar _isar;

  @override
  Stream<List<Wallet>> watchWallets() {
    return _isar.wallets.where().sortByCreatedAt().watch(fireImmediately: true);
  }

  @override
  Future<List<Wallet>> getWallets() {
    return _isar.wallets.where().sortByCreatedAt().findAll();
  }

  @override
  Future<Wallet?> getWallet(int id) {
    return _isar.wallets.get(id);
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

    return _isar.writeTxn(() async {
      final wallet = (id != null && id > 0)
          ? (await _isar.wallets.get(id) ?? Wallet())
          : Wallet();

      if (id != null && id > 0) {
        wallet.id = id;
      } else {
        wallet.createdAt = DateTime.now();
      }
      wallet.name = trimmed;
      wallet.icon = icon;
      wallet.startingBalance = startingBalance;
      wallet.includeInDailyBudget = includeInDailyBudget;

      final savedId = await _isar.wallets.put(wallet);
      wallet.id = savedId;
      return wallet;
    });
  }

  @override
  Future<void> deleteWallet(int id) async {
    final count = await _isar.wallets.count();
    if (count <= 1) {
      throw const WalletDeleteRestrictedException();
    }

    // Check if wallet has referencing transactions (FR-12)
    final hasTxs = await _isar.transactions
        .filter()
        .walletIdEqualTo(id)
        .or()
        .transferPeerWalletIdEqualTo(id)
        .findFirst();

    if (hasTxs != null) {
      throw const WalletHasTransactionsException();
    }

    await _isar.writeTxn(() async {
      await _isar.wallets.delete(id);
    });
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
      ..type = db.TransactionType.transfer
      ..amount = amount
      ..categoryId = 0
      ..walletId = sourceWalletId
      ..transferPeerWalletId = targetWalletId
      ..transferGroupId = 'trf_${DateTime.now().microsecondsSinceEpoch}'
      ..date = date
      ..notes = notes?.trim().isEmpty == true ? null : notes?.trim();

    return _isar.writeTxn(() async {
      final id = await _isar.transactions.put(tx);
      tx.id = id;
      return tx;
    });
  }
}
