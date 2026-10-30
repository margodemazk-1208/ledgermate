import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/transaction.dart' as db;
import '../../../core/presentation/widgets/press_scale.dart';
import '../../../core/presentation/widgets/success_toast.dart';
import '../../../core/presentation/widgets/unsaved_changes_guard.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../wallets/application/wallet_providers.dart';
import '../../wallets/utils/wallet_icons.dart';
import '../application/transaction_providers.dart';
import '../data/transaction_repository.dart';

/// Screen for adding a new transaction or editing an existing one (FR-02, FR-03).
class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key, this.transaction, this.initialType});

  final db.Transaction? transaction;

  /// Pre-selects the Pengeluaran/Pemasukan toggle for a brand-new transaction
  /// (e.g. opened from the Home FAB speed-dial's "Catat Pemasukan" option).
  /// Ignored when editing an existing [transaction].
  final db.TransactionType? initialType;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  String? _amountError;

  // M19/D18: unsaved-changes guard — any field edit marks the form dirty
  // so back-navigation confirms before discarding (see
  // UnsavedChangesGuard doc comment). Needs `setState` because
  // `UnsavedChangesGuard`'s `PopScope.canPop` only re-evaluates on rebuild.
  bool _dirty = false;
  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    // Initialize notifier state for edit or add
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionFormProvider.notifier).init(tx);
      if (tx == null && widget.initialType != null) {
        ref.read(transactionFormProvider.notifier).setType(widget.initialType!);
      }
    });

    _amountController = TextEditingController(
      text: tx == null ? '' : formatRupiah(tx.amount).replaceAll('Rp ', ''),
    );
    _notesController = TextEditingController(text: tx?.notes ?? '');
    _amountController.addListener(_markDirty);
    _notesController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    final parsed = parseRupiah(value);
    ref.read(transactionFormProvider.notifier).setAmount(parsed);
    setState(() {
      _amountError = validateRupiahAmount(
        value,
        emptyMessage: 'Jumlah tidak boleh kosong',
        invalidMessage: 'Jumlah tidak boleh nol atau negatif',
      );
    });
  }

  Future<void> _pickDate(BuildContext context, DateTime currentDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      ref.read(transactionFormProvider.notifier).setDate(picked);
      _markDirty();
    }
  }

  Future<void> _onSave() async {
    final formNotifier = ref.read(transactionFormProvider.notifier);
    final amountText = _amountController.text;
    final err = validateRupiahAmount(
      amountText,
      emptyMessage: 'Jumlah tidak boleh kosong',
      invalidMessage: 'Jumlah tidak boleh nol atau negatif',
    );
    if (err != null) {
      setState(() => _amountError = err);
      return;
    }

    final success = await formNotifier.save();
    if (success && mounted) {
      showSuccessToast(context, 'Transaksi berhasil disimpan');
      _dirty = false;
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi?'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          PressScale(
            child: FilledButton(
              key: const ValueKey('transaction_delete_confirm_button'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.expenseRed,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Hapus'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(transactionFormProvider.notifier).delete();
      if (success && mounted) {
        _dirty = false;
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final walletsAsync = ref.watch(walletsStreamProvider);
    final isEdit = widget.transaction != null;

    // Auto-select first wallet if none is selected yet and wallets are ready
    walletsAsync.whenData((wallets) {
      if (formState.walletId == null && wallets.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(transactionFormProvider.notifier)
              .setWallet(wallets.first.id);
        });
      }
    });

    // Auto-select first category if none is selected yet and categories are ready
    categoriesAsync.whenData((categories) {
      if (formState.categoryId == null && categories.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(transactionFormProvider.notifier)
              .setCategory(categories.first.id);
        });
      }
    });

    final dateFormatted = DateFormat('d MMMM yyyy').format(formState.date);
    final isToday = isTransactionDeletable(formState.date);

    return UnsavedChangesGuard(
      isDirty: () => _dirty,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit ? 'Edit Transaksi' : 'Catat Transaksi',
            style: AppTypography.script(fontSize: 20),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Transaction Type Toggle (Pengeluaran vs Pemasukan vs Transfer)
              // Custom toggle-group per style.css `.toggle-group`/`.toggle-option`
              // (the mockup shows a 2-way toggle; this app also supports Transfer
              // per FR-13/D16, so a 3-way segment keeps the same visual language).
              _TypeToggleGroup(
                selected: formState.type,
                onChanged: (type) {
                  ref.read(transactionFormProvider.notifier).setType(type);
                  _markDirty();
                },
              ),
              const SizedBox(height: 28),

              // 2. Amount field — large centered display per 03_tambah_transaksi.html
              Column(
                children: [
                  Text(
                    formState.type == db.TransactionType.transfer
                        ? 'NOMINAL TRANSFER'
                        : 'JUMLAH',
                    style: AppTypography.mono(
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const ValueKey('transaction_amount_field'),
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RupiahInputFormatter()],
                    onChanged: _onAmountChanged,
                    textAlign: TextAlign.center,
                    style: AppTypography.mono(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      filled: false,
                      prefixText: 'Rp ',
                      prefixStyle: AppTypography.mono(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                      errorText: _amountError,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Wallet and Category pickers
              if (formState.type == db.TransactionType.transfer) ...[
                // Source Wallet
                walletsAsync.when(
                  data: (wallets) {
                    final selectedValue =
                        wallets.any((w) => w.id == formState.walletId)
                        ? formState.walletId
                        : (wallets.isNotEmpty ? wallets.first.id : null);

                    return DropdownButtonFormField<int>(
                      key: const ValueKey('transaction_wallet_picker'),
                      initialValue: selectedValue,
                      decoration: const InputDecoration(
                        labelText: 'Dari Dompet (Sumber)',
                        border: OutlineInputBorder(),
                      ),
                      items: wallets.map((w) {
                        return DropdownMenuItem<int>(
                          value: w.id,
                          child: Row(
                            children: [
                              Icon(getWalletIcon(w.icon), size: 18),
                              const SizedBox(width: 8),
                              Text(w.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (wid) {
                        if (wid != null) {
                          ref
                              .read(transactionFormProvider.notifier)
                              .setWallet(wid);
                          _markDirty();
                        }
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text(
                    'Gagal memuat dompet: $err',
                    style: const TextStyle(color: AppColors.expenseRed),
                  ),
                ),
                const SizedBox(height: 20),

                // Target Wallet
                walletsAsync.when(
                  data: (wallets) {
                    final targetWallets = wallets
                        .where((w) => w.id != formState.walletId)
                        .toList();
                    final selectedTarget =
                        targetWallets.any(
                          (w) => w.id == formState.transferPeerWalletId,
                        )
                        ? formState.transferPeerWalletId
                        : (targetWallets.isNotEmpty
                              ? targetWallets.first.id
                              : null);

                    return DropdownButtonFormField<int>(
                      key: const ValueKey('transaction_target_wallet_picker'),
                      initialValue: selectedTarget,
                      decoration: const InputDecoration(
                        labelText: 'Ke Dompet (Tujuan)',
                        border: OutlineInputBorder(),
                      ),
                      items: targetWallets.map((w) {
                        return DropdownMenuItem<int>(
                          value: w.id,
                          child: Row(
                            children: [
                              Icon(getWalletIcon(w.icon), size: 18),
                              const SizedBox(width: 8),
                              Text(w.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (wid) {
                        if (wid != null) {
                          ref
                              .read(transactionFormProvider.notifier)
                              .setTransferPeerWallet(wid);
                          _markDirty();
                        }
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text(
                    'Gagal memuat dompet tujuan: $err',
                    style: const TextStyle(color: AppColors.expenseRed),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                // Regular Wallet picker
                walletsAsync.when(
                  data: (wallets) {
                    final selectedValue =
                        wallets.any((w) => w.id == formState.walletId)
                        ? formState.walletId
                        : (wallets.isNotEmpty ? wallets.first.id : null);

                    return DropdownButtonFormField<int>(
                      key: const ValueKey('transaction_wallet_picker'),
                      initialValue: selectedValue,
                      decoration: const InputDecoration(
                        labelText: 'Dompet',
                        border: OutlineInputBorder(),
                      ),
                      items: wallets.map((w) {
                        return DropdownMenuItem<int>(
                          value: w.id,
                          child: Row(
                            children: [
                              Icon(getWalletIcon(w.icon), size: 18),
                              const SizedBox(width: 8),
                              Text(w.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (wid) {
                        if (wid != null) {
                          ref
                              .read(transactionFormProvider.notifier)
                              .setWallet(wid);
                          _markDirty();
                        }
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text(
                    'Gagal memuat dompet: $err',
                    style: const TextStyle(color: AppColors.expenseRed),
                  ),
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                categoriesAsync.when(
                  data: (categories) {
                    final selectedValue =
                        categories.any((c) => c.id == formState.categoryId)
                        ? formState.categoryId
                        : (categories.isNotEmpty ? categories.first.id : null);

                    return DropdownButtonFormField<int>(
                      key: const ValueKey('transaction_category_picker'),
                      initialValue: selectedValue,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (catId) {
                        if (catId != null) {
                          ref
                              .read(transactionFormProvider.notifier)
                              .setCategory(catId);
                          _markDirty();
                        }
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, _) => Text(
                    'Gagal memuat kategori: $err',
                    style: const TextStyle(color: AppColors.expenseRed),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 4. Date Picker
              InkWell(
                key: const ValueKey('transaction_date_picker'),
                onTap: () => _pickDate(context, formState.date),
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    dateFormatted,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Notes (optional)
              TextField(
                key: const ValueKey('transaction_notes_field'),
                controller: _notesController,
                onChanged: (val) {
                  ref.read(transactionFormProvider.notifier).setNotes(val);
                },
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Error banner if submit failed
              if (formState.submitError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.expenseRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.expenseRed),
                  ),
                  child: Text(
                    formState.submitError!,
                    style: const TextStyle(color: AppColors.expenseRed),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 6. Save Button (disabled while submitting or if amount invalid)
              PressScale(
                enabled: !formState.isSubmitting,
                child: FilledButton(
                  key: const ValueKey('transaction_save_button'),
                  onPressed: formState.isSubmitting ? null : _onSave,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: formState.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit ? 'Simpan Perubahan' : 'Simpan Transaksi',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),

              // 7. Edit mode delete section
              if (isEdit) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                if (isToday) ...[
                  // Today transaction: delete is allowed
                  PressScale(
                    enabled: !formState.isSubmitting,
                    child: OutlinedButton.icon(
                      key: const ValueKey('transaction_delete_button'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expenseRed,
                        side: const BorderSide(color: AppColors.expenseRed),
                      ),
                      onPressed: formState.isSubmitting ? null : _onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus Transaksi'),
                    ),
                  ),
                ] else ...[
                  // Older transaction: delete is blocked in UI (FR-03)
                  OutlinedButton.icon(
                    key: const ValueKey('transaction_delete_button_disabled'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).disabledColor,
                    ),
                    onPressed: null,
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Hapus Transaksi (Terkunci)'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.warningAmber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hanya transaksi bertanggal hari ini yang dapat dihapus. '
                          'Transaksi lampau tidak dapat dihapus untuk menjaga integritas histori (FR-03).',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.warningAmber),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// `.toggle-group`/`.toggle-option` pattern per style.css: equal-flex
/// segments, selected = burgundy fill. Mirrors SegmentedButton's selection
/// behavior/text so existing `find.text('Pemasukan')`-style test taps work.
class _TypeToggleGroup extends StatelessWidget {
  const _TypeToggleGroup({required this.selected, required this.onChanged});

  final db.TransactionType selected;
  final ValueChanged<db.TransactionType> onChanged;

  static const _options = [
    (db.TransactionType.expense, 'Pengeluaran', Icons.arrow_upward),
    (db.TransactionType.income, 'Pemasukan', Icons.arrow_downward),
    (db.TransactionType.transfer, 'Transfer', Icons.swap_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.darkSurface2
            : AppColors.lightSurface2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final (type, label, icon) in _options)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(type),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected == type
                        ? AppColors.burgundy
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: selected == type
                            ? Colors.white
                            : theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: AppTypography.mono(
                          fontSize: 12,
                          fontWeight: selected == type
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: selected == type
                              ? Colors.white
                              : theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
