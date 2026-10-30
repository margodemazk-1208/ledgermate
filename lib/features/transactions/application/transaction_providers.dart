// Riverpod providers for M3 Transactions (FR-02, FR-03).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/category.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/transaction.dart' as db;
import '../../notifications/application/limit_alert_hook.dart';
import '../data/transaction_repository.dart';

/// Sentinel codes for [TransactionFormState.submitError] set by validation
/// failures in [TransactionFormNotifier.save] (application layer — no
/// `BuildContext` here to resolve `AppLocalizations`). The presentation
/// layer maps these to localized messages; any other `submitError` value
/// is an arbitrary repository exception's `toString()` and is shown as-is
/// (localizing arbitrary exception text is out of scope for M20).
const transactionInvalidTransferErrorCode = '__transaction_invalid_transfer__';
const transactionInvalidRegularErrorCode = '__transaction_invalid_regular__';

final transactionRepositoryProvider = Provider<TransactionRepositoryBase>((
  ref,
) {
  return TransactionRepository(ref.watch(isarProvider));
});

/// Reactive stream of transactions, reverse-chronological.
///
/// M18/D18 perf item 2: the real Isar subscription behind this (and behind
/// `budgetTransactionsStreamProvider` and
/// `analyticsTransactionsStreamProvider`) is shared via
/// `core/database/transactions_watch.dart`'s `watchAllTransactionsShared` —
/// see that file's doc comment. Pre-M18 these 3 providers each ran through
/// a repository that opened its OWN independent
/// `isar.transactions.where().sortByDateDesc().watch(...)`, i.e. 3 separate
/// full-table re-queries/re-sorts on every single transaction write.
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
    this.createdAt,
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

  /// The transaction's ORIGINAL creation timestamp (D18/M16 bug #6) — `null`
  /// for brand-new (not-yet-saved) transactions and for pre-M16 legacy rows
  /// with no recorded `createdAt`. [canDelete] checks this instead of
  /// [date] so editing a historical transaction's date to today can never
  /// resurrect delete eligibility.
  final DateTime? createdAt;

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
    if (type == db.TransactionType.income) {
      return true;
    }
    return (categoryId != null && categoryId! > 0);
  }

  /// Checks if this transaction is eligible for delete (FR-03: restricted to
  /// transactions ORIGINALLY CREATED today — see [createdAt] doc).
  bool get canDelete {
    if (!isEditMode) return false;
    return isTransactionDeletable(createdAt ?? date);
  }

  TransactionFormState copyWith({
    db.TransactionType? type,
    int? amount,
    int? categoryId,
    int? walletId,
    int? transferPeerWalletId,
    String? transferGroupId,
    bool clearTransferFields = false,
    DateTime? date,
    String? notes,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    int? initialTransactionId,
    DateTime? createdAt,
  }) {
    return TransactionFormState(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      transferPeerWalletId: clearTransferFields
          ? null
          : (transferPeerWalletId ?? this.transferPeerWalletId),
      transferGroupId: clearTransferFields
          ? null
          : (transferGroupId ?? this.transferGroupId),
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      initialTransactionId: initialTransactionId ?? this.initialTransactionId,
      createdAt: createdAt ?? this.createdAt,
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
        createdAt: tx.createdAt,
      );
    } else {
      state = TransactionFormState(date: DateTime.now());
    }
  }

  void setType(db.TransactionType type) {
    // D18/M16 bug #10: clear any dangling transfer peer/group reference the
    // moment the user switches away from `transfer` in the form itself —
    // the data-layer fix in `TransactionRepository.saveTransaction` is the
    // authoritative one, but clearing it here too avoids briefly showing a
    // stale peer-wallet selection in the UI.
    state = state.copyWith(
      type: type,
      clearTransferFields: type != db.TransactionType.transfer,
    );
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
  ///
  /// D18/M17 bug #8: re-entrancy guard so a double-tap on "Simpan" before
  /// the first save's `isSubmitting: true` has been reflected in a rebuilt
  /// UI cannot write the same transaction twice — see
  /// `pay_cycle_providers.dart`'s `submitTransition` for the identical
  /// pattern and rationale.
  Future<bool> save() async {
    if (state.isSubmitting) return false;
    if (!state.isValid) {
      if (state.type == db.TransactionType.transfer) {
        state = state.copyWith(
          submitError: transactionInvalidTransferErrorCode,
        );
      } else {
        state = state.copyWith(submitError: transactionInvalidRegularErrorCode);
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
                : (state.type == db.TransactionType.income
                      ? await ref
                            .read(transactionRepositoryProvider)
                            .resolveSystemIncomeCategoryId()
                      : state.categoryId!),
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
    if (state.isSubmitting) return false;
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
    NotifierProvider.autoDispose<TransactionFormNotifier, TransactionFormState>(
      TransactionFormNotifier.new,
    );
