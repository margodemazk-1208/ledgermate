import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/presentation/widgets/press_scale.dart';
import '../../../core/presentation/widgets/success_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../application/wallet_providers.dart';
import '../utils/wallet_icons.dart';

/// Dedicated Inter-Wallet Transfer Screen (FR-13, D16).
class TransferFormScreen extends ConsumerStatefulWidget {
  const TransferFormScreen({super.key, this.initialSourceWalletId});

  final int? initialSourceWalletId;

  @override
  ConsumerState<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends ConsumerState<TransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  int? _sourceWalletId;
  int? _targetWalletId;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
    _sourceWalletId = widget.initialSourceWalletId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // D18/M17 bug #8: re-entrancy guard against double-tap.
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_sourceWalletId == null || _targetWalletId == null) {
      setState(() {
        _errorMessage = 'Pilih dompet asal dan tujuan transfer.';
      });
      return;
    }

    if (_sourceWalletId == _targetWalletId) {
      setState(() {
        _errorMessage = 'Dompet asal dan tujuan tidak boleh sama.';
      });
      return;
    }

    final amount = parseRupiah(_amountController.text) ?? 0;
    if (amount <= 0) {
      setState(() {
        _errorMessage = 'Nominal transfer harus lebih besar dari nol.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(walletRepositoryProvider)
          .transfer(
            sourceWalletId: _sourceWalletId!,
            targetWalletId: _targetWalletId!,
            amount: amount,
            date: _date,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (mounted) {
        showSuccessToast(
          context,
          'Transfer ${formatRupiah(amount)} berhasil diproses',
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(walletsStreamProvider);
    final balancesAsync = ref.watch(walletBalancesProvider);
    final balances = balancesAsync.value ?? const <int, int>{};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transfer Antar Dompet',
          style: AppTypography.script(fontSize: 18),
        ),
      ),
      body: walletsAsync.when(
        data: (wallets) {
          if (wallets.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.swap_horiz_outlined,
                      size: 48,
                      color: AppColors.warningAmber,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Butuh minimal 2 dompet untuk melakukan transfer.',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan dompet lain terlebih dahulu di menu Kelola Dompet.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Initialize defaults if not set
          if (_sourceWalletId == null && wallets.isNotEmpty) {
            _sourceWalletId = wallets.first.id;
          }
          if (_targetWalletId == null && wallets.length > 1) {
            _targetWalletId = wallets
                .firstWhere((w) => w.id != _sourceWalletId)
                .id;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error message banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.expenseRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.expenseRed.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.expenseRed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.expenseRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Source Wallet Dropdown
                  DropdownButtonFormField<int>(
                    key: const ValueKey('transfer_source_wallet_picker'),
                    initialValue: _sourceWalletId,
                    decoration: const InputDecoration(
                      labelText: 'Dari Dompet (Sumber)',
                      border: OutlineInputBorder(),
                    ),
                    items: wallets.map((w) {
                      final bal = balances[w.id] ?? w.startingBalance;
                      return DropdownMenuItem<int>(
                        value: w.id,
                        child: Row(
                          children: [
                            Icon(getWalletIcon(w.icon), size: 20),
                            const SizedBox(width: 8),
                            Text('${w.name} (${formatRupiah(bal)})'),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (wid) {
                      setState(() {
                        _sourceWalletId = wid;
                        if (_targetWalletId == wid) {
                          _targetWalletId = wallets
                              .firstWhere(
                                (w) => w.id != wid,
                                orElse: () => wallets.first,
                              )
                              .id;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Target Wallet Dropdown
                  DropdownButtonFormField<int>(
                    key: const ValueKey('transfer_target_wallet_picker'),
                    initialValue: _targetWalletId,
                    decoration: const InputDecoration(
                      labelText: 'Ke Dompet (Tujuan)',
                      border: OutlineInputBorder(),
                    ),
                    items: wallets.where((w) => w.id != _sourceWalletId).map((
                      w,
                    ) {
                      final bal = balances[w.id] ?? w.startingBalance;
                      return DropdownMenuItem<int>(
                        value: w.id,
                        child: Row(
                          children: [
                            Icon(getWalletIcon(w.icon), size: 20),
                            const SizedBox(width: 8),
                            Text('${w.name} (${formatRupiah(bal)})'),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (wid) {
                      setState(() {
                        _targetWalletId = wid;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Amount Field
                  TextFormField(
                    key: const ValueKey('transfer_amount_field'),
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RupiahInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Nominal Transfer',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      final parsed = parseRupiah(val ?? '') ?? 0;
                      if (parsed <= 0) {
                        return 'Nominal transfer harus lebih besar dari nol';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Date picker tile
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Transfer',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('d MMMM yyyy').format(_date),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notes Field
                  TextFormField(
                    key: const ValueKey('transfer_notes_field'),
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      hintText: 'Misal: Tarik tunai dari ATM, Top up GoPay',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  PressScale(
                    enabled: !_isSubmitting,
                    child: FilledButton.icon(
                      key: const ValueKey('transfer_submit_button'),
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.swap_horiz),
                      label: const Text('Transfer Sekarang'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat dompet: $err',
              style: const TextStyle(color: AppColors.expenseRed),
            ),
          ),
        ),
      ),
    );
  }
}
