import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/pay_cycle.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../application/onboarding_providers.dart';
import 'onboarding_step_header.dart';

/// Step (c): input mandatory expenses list (name + amount, add multiple).
/// PRD §7.2 BR-02 — list is empty-by-default (not every user has
/// recurring obligations); each added row is validated before it's kept.
class MandatoryExpensesStep extends ConsumerStatefulWidget {
  const MandatoryExpensesStep({super.key});

  @override
  ConsumerState<MandatoryExpensesStep> createState() =>
      _MandatoryExpensesStepState();
}

class _MandatoryExpensesStepState extends ConsumerState<MandatoryExpensesStep> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String? _nameError;
  String? _amountError;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addExpense() {
    final name = _nameController.text.trim();
    final amount = parseRupiah(_amountController.text);
    final nameError = name.isEmpty ? 'Nama tidak boleh kosong' : null;
    final amountError = validateRupiahAmount(
      _amountController.text,
      emptyMessage: 'Jumlah tidak boleh kosong',
      invalidMessage: 'Jumlah tidak boleh negatif atau nol',
    );
    setState(() {
      _nameError = nameError;
      _amountError = amountError;
    });
    if (nameError != null || amountError != null) return;

    ref
        .read(onboardingWizardProvider.notifier)
        .addExpense(
          MandatoryExpenseItem()
            ..name = name
            ..amount = amount!,
        );
    _nameController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(
      onboardingWizardProvider.select((s) => s.expenses),
    );
    final notifier = ref.read(onboardingWizardProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            stepIndex: 3,
            totalSteps: 4,
            title: 'Pengeluaran Wajib',
            subtitle:
                'Kos, cicilan, dll — opsional, tambahkan sebanyak yang '
                'kamu perlukan.',
          ),
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Belum ada pengeluaran wajib ditambahkan.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...expenses.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                key: ValueKey('expense_row_$index'),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(formatRupiah(item.amount)),
                  trailing: IconButton(
                    key: ValueKey('remove_expense_$index'),
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.expenseRed,
                    ),
                    onPressed: () => notifier.removeExpenseAt(index),
                  ),
                ),
              );
            }),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('expense_name_field'),
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama pengeluaran',
              errorText: _nameError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('expense_amount_field'),
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [RupiahInputFormatter()],
            decoration: InputDecoration(
              labelText: 'Jumlah',
              prefixText: 'Rp ',
              errorText: _amountError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const ValueKey('add_expense_button'),
              onPressed: _addExpense,
              icon: const Icon(Icons.add),
              label: const Text('Tambah pengeluaran'),
            ),
          ),
        ],
      ),
    );
  }
}
