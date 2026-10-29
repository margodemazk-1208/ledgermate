// Riverpod providers for M3 Transactions (FR-02, FR-03).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/category.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/transaction.dart' as db;
import '../../notifications/application/limit_alert_hook.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepositoryBase>((
  ref,
) {
  return TransactionRepository(ref.watch(isarProvider));
});

/// Reactive stream of transactions, reverse-chronological.
final transactionsStreamProvider = StreamProvider<List<db.Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchTransactions();
});

/// Reactive stream of categories, seeding defaults first if collection is empty.
final categoriesStreamProvider = StreamProvider<List<Category>>((ref) async* {
  final repo = ref.watch(transactionRepositoryProvider);
  await repo.seedDefaultCategories();
  yield* repo.watchCategories();
});

/// Convenient O(1) map of category id -> Category for list item decoration.
final categoriesMapProvider = Provider<Map<int, Category>>((ref) {
  final categoriesAsync = ref.watch(categoriesStreamProvider);
  return categoriesAsync.maybeWhen(
    data: (categories) => {for (final c in categories) c.id: c},
    orElse: () => const <int, Category>{},
  );
});

class TransactionFormState {
  const TransactionFormState({
    this.type = db.TransactionType.expense,
    this.amount,
    this.categoryId,
    this.walletId,
    this.transferPeerWalletId,
    this.transferGroupId,
    required this.date,
    this.notes,
    this.isSubmitting = false,
    this.submitError,
    this.initialTransactionId,
  });

  final db.TransactionType type;
  final int? amount;
  final int? categoryId;
  final int? walletId;
  final int? transferPeerWalletId;
  final String? transferGroupId;
  final DateTime date;
  final String? notes;
  final bool isSubmitting;
  final String? submitError;
  final int? initialTransactionId;

  bool get isEditMode => initialTransactionId != null;

  bool get isValid {
    final hasAmount = amount != null && amount! > 0;
    if (!hasAmount) return false;
    if (type == db.TransactionType.transfer) {
      return (walletId != null && walletId! > 0) &&
          (transferPeerWalletId != null &&
              transferPeerWalletId! > 0 &&
              transferPeerWalletId != walletId);
    }
    return (categoryId != null && categoryId! > 0);
  }

  /// Checks if this transaction is dated today (FR-03: today-only delete restriction).
  bool get canDelete {
    if (!isEditMode) return false;
    return isTransactionDeletable(date);
  }

  TransactionFormState copyWith({
    db.TransactionType? type,
    int? amount,
    int? categoryId,
    int? walletId,
    int? transferPeerWalletId,
    String? transferGroupId,
    DateTime? date,
    String? notes,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    int? initialTransactionId,
  }) {
    return TransactionFormState(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      transferPeerWalletId: transferPeerWalletId ?? this.transferPeerWalletId,
      transferGroupId: transferGroupId ?? this.transferGroupId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      initialTransactionId: initialTransactionId ?? this.initialTransactionId,
    );
  }
}

class TransactionFormNotifier extends Notifier<TransactionFormState> {
  @override
  TransactionFormState build() {
    return TransactionFormState(date: DateTime.now());
  }

  /// Initializes the form with an existing transaction for edit mode, or defaults for add mode.
  void init(db.Transaction? tx) {
    if (tx != null) {
      state = TransactionFormState(
        type: tx.type,
        amount: tx.amount,
        categoryId: tx.categoryId,
        walletId: tx.walletId,
        transferPeerWalletId: tx.transferPeerWalletId,
        transferGroupId: tx.transferGroupId,
        date: tx.date,
        notes: tx.notes,
        initialTransactionId: tx.id,
      );
    } else {
      state = TransactionFormState(date: DateTime.now());
    }
  }

  void setType(db.TransactionType type) {
    state = state.copyWith(type: type);
  }

  void setWallet(int walletId) {
    state = state.copyWith(walletId: walletId, clearSubmitError: true);
  }

  void setTransferPeerWallet(int targetWalletId) {
    state = state.copyWith(
      transferPeerWalletId: targetWalletId,
      clearSubmitError: true,
    );
  }

  void setAmount(int? amount) {
    state = state.copyWith(amount: amount, clearSubmitError: true);
  }

  void setCategory(int categoryId) {
    state = state.copyWith(categoryId: categoryId, clearSubmitError: true);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  /// Validates and persists the transaction via [TransactionRepositoryBase].
  Future<bool> save() async {
    if (!state.isValid) {
      if (state.type == db.TransactionType.transfer) {
        state = state.copyWith(
          submitError: 'Mohon masukkan nominal dan pilih dompet asal & tujuan yang berbeda.',
        );
      } else {
        state = state.copyWith(
          submitError: 'Mohon masukkan jumlah dan pilih kategori.',
        );
      }
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);
    try {
      await ref
          .read(transactionRepositoryProvider)
          .saveTransaction(
            id: state.initialTransactionId,
            type: state.type,
            amount: state.amount!,
            categoryId: state.type == db.TransactionType.transfer
                ? 0
                : state.categoryId!,
            date: state.date,
            notes: state.notes,
            walletId: state.walletId,
            transferPeerWalletId: state.transferPeerWalletId,
            transferGroupId: state.transferGroupId,
          );
      await ref.read(limitAlertHookProvider).onTransactionSaved();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submitError: e.toString());
      return false;
    }
  }

  /// Deletes the current transaction if dated today, enforcing FR-03.
  Future<bool> delete() async {
    final id = state.initialTransactionId;
    if (id == null) return false;

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);
    try {
      await ref.read(transactionRepositoryProvider).deleteTransaction(id);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submitError: e.toString());
      return false;
    }
  }
}

final transactionFormProvider =
    NotifierProvider<TransactionFormNotifier, TransactionFormState>(
      TransactionFormNotifier.new,
    );
