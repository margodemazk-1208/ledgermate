// FR-06c Withdraw dialog and confirmation per PRD §7.3 BR-03.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/financial_goal.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../application/goals_providers.dart';

class WithdrawDialog extends ConsumerStatefulWidget {
  const WithdrawDialog({super.key, required this.goal});

  final FinancialGoal goal;

  @override
  ConsumerState<WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends ConsumerState<WithdrawDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int? _parseAmount() {
    return parseRupiah(_amountController.text);
  }

  void _setPresetPercentage(double percent) {
    final amount = (widget.goal.currentAmount * percent).round();
    _amountController.text = formatRupiah(amount);
    setState(() {
      _errorMsg = null;
    });
  }

  Future<void> _handleWithdraw() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      setState(() => _errorMsg = 'Nominal harus lebih besar dari 0.');
      return;
    }
    if (amount > widget.goal.currentAmount) {
      setState(() => _errorMsg = 'Nominal melebihi tabungan saat ini.');
      return;
    }

    // PRD FR-06c: "Konfirmasi dialog ditampilkan sebelum penarikan diproses"
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Konfirmasi Penarikan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Tarik ${formatRupiah(amount)} dari target "${widget.goal.goalName}"?\n\n'
          'Saldo target akan berkurang dan nominal ini akan otomatis kembali ke saldo aktif periode berjalan.',
        ),
        actions: [
          TextButton(
            key: const ValueKey('withdraw_confirm_cancel_button'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const ValueKey('withdraw_confirm_submit_button'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.brandTeal),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Tarik Sekarang'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
    });

    try {
      await ref
          .read(goalsRepositoryProvider)
          .withdrawFromGoal(goalId: widget.goal.id, amount: amount);
      if (mounted) {
        Navigator.of(context).pop(amount);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMsg = 'Gagal melakukan penarikan: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.outbox, color: AppColors.brandTeal, size: 26),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Tarik dari Goal',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target: ${widget.goal.goalName}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tersedia saat ini: ${formatRupiah(widget.goal.currentAmount)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.savingsGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('withdraw_amount_field'),
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal Penarikan',
                hintText: 'Rp 0',
                prefixIcon: Icon(Icons.money),
              ),
              validator: (val) {
                final parsed = parseRupiah(val ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Masukkan nominal yang valid';
                }
                if (parsed > widget.goal.currentAmount) {
                  return 'Melebihi saldo terkumpul';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionChip(
                  key: const ValueKey('withdraw_chip_25'),
                  label: const Text('25%'),
                  onPressed: () => _setPresetPercentage(0.25),
                ),
                ActionChip(
                  key: const ValueKey('withdraw_chip_50'),
                  label: const Text('50%'),
                  onPressed: () => _setPresetPercentage(0.50),
                ),
                ActionChip(
                  key: const ValueKey('withdraw_chip_100'),
                  label: const Text('Semua'),
                  onPressed: () => _setPresetPercentage(1.0),
                ),
              ],
            ),
            if (_errorMsg != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMsg!,
                style: const TextStyle(
                  color: AppColors.expenseRed,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('withdraw_cancel_button'),
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const ValueKey('withdraw_submit_button'),
          onPressed: _isSubmitting ? null : _handleWithdraw,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Lanjut Tarik'),
        ),
      ],
    );
  }
}
