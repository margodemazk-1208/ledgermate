// M5 Pay Cycle Transition Screen (FR-05, BR-02).
//
// Provides the UI for transitioning to a new pay cycle (Mode A)
// or executing daily carry-over rollover (Mode B).
// Complies with BR-02 (manual re-entry, no auto-populated templates/defaults)
// and antislop guidelines (empty/loading/error states, dark/light theme, real handlers).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../budget_engine/application/budget_providers.dart';
import '../application/pay_cycle_providers.dart';
import '../application/pay_cycle_transition_state.dart';

class PayCycleTransitionScreen extends ConsumerStatefulWidget {
  const PayCycleTransitionScreen({super.key, this.referenceNow});

  final DateTime? referenceNow;

  @override
  ConsumerState<PayCycleTransitionScreen> createState() =>
      _PayCycleTransitionScreenState();
}

class _PayCycleTransitionScreenState
    extends ConsumerState<PayCycleTransitionScreen> {
  late final TextEditingController _salaryController;
  late final TextEditingController _bekelController;
  final _expenseNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  String? _salaryError;
  String? _expenseNameError;
  String? _expenseAmountError;

  @override
  void initState() {
    super.initState();
    _salaryController = TextEditingController();
    _bekelController = TextEditingController();
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _bekelController.dispose();
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  void _onSalaryChanged(String val) {
    final l10n = AppLocalizations.of(context)!;
    final parsed = parseRupiah(val);
    ref
        .read(payCycleTransitionNotifierProvider.notifier)
        .setFixedSalary(parsed);
    setState(() {
      _salaryError = validateRupiahAmount(
        val,
        emptyMessage: l10n.payCycleTransitionScreenSalaryEmptyError,
        invalidMessage: l10n.payCycleTransitionScreenSalaryInvalidError,
      );
    });
  }

  void _onBekelChanged(String val) {
    final parsed = parseRupiah(val);
    ref.read(payCycleTransitionNotifierProvider.notifier).setTodayBekel(parsed);
  }

  void _addExpense(bool isPeriodic) {
    final l10n = AppLocalizations.of(context)!;
    final name = _expenseNameController.text.trim();
    final amount = parseRupiah(_expenseAmountController.text);
    final nameError = name.isEmpty
        ? l10n.payCycleTransitionScreenExpenseNameEmptyError
        : null;
    final amountError = validateRupiahAmount(
      _expenseAmountController.text,
      emptyMessage: l10n.payCycleTransitionScreenAmountEmptyError,
      invalidMessage: l10n.payCycleTransitionScreenAmountInvalidError,
    );

    setState(() {
      _expenseNameError = nameError;
      _expenseAmountError = amountError;
    });

    if (nameError != null || amountError != null) return;

    final item = MandatoryExpenseItem()
      ..name = name
      ..amount = amount!;

    final notifier = ref.read(payCycleTransitionNotifierProvider.notifier);
    if (isPeriodic) {
      notifier.addMandatoryExpense(item);
    } else {
      notifier.addTodayMandatoryExpense(item);
    }

    _expenseNameController.clear();
    _expenseAmountController.clear();
  }

  /// Maps a [PayCycleTransitionState.submitError] sentinel code (set by the
  /// application-layer `canSubmit` guard, which has no `BuildContext`) to a
  /// localized message. Any other value is an arbitrary repository
  /// exception's `toString()`, shown as-is (out of scope for M20).
  String _resolveSubmitError(AppLocalizations l10n, String code) {
    if (code == payCycleTransitionIncompleteDataErrorCode) {
      return l10n.payCycleTransitionScreenIncompleteDataError;
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(budgetProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.payCycleTransitionScreenTitle)),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: ValueKey('transition_loading_indicator'),
          ),
        ),
        error: (err, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.expenseRed,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.payCycleTransitionScreenLoadProfileError(err),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Text(l10n.payCycleTransitionScreenProfileNotFound),
            );
          }

          final state = ref.watch(payCycleTransitionNotifierProvider);
          final isPeriodic = state.isPeriodic;

          ref.listen(payCycleTransitionNotifierProvider, (prev, next) {
            if (next.submitError != null &&
                next.submitError != prev?.submitError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_resolveSubmitError(l10n, next.submitError!)),
                  backgroundColor: AppColors.expenseRed,
                ),
              );
            }
            if (next.isSuccess && !(prev?.isSuccess ?? false)) {
              Navigator.of(context).pop(true);
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeaderSection(isPeriodic: isPeriodic),
                const SizedBox(height: 24),
                if (isPeriodic) ...[
                  _ModeAIntervalAndDatePicker(
                    state: state,
                    referenceNow: widget.referenceNow ?? DateTime.now(),
                  ),
                  const SizedBox(height: 20),
                  _ModeASalaryInput(
                    controller: _salaryController,
                    errorText: _salaryError,
                    onChanged: _onSalaryChanged,
                  ),
                ] else ...[
                  _ModeBCarryOverCard(carryOver: state.yesterdayCarryOver),
                  const SizedBox(height: 20),
                  _ModeBBekelInput(
                    controller: _bekelController,
                    onChanged: _onBekelChanged,
                  ),
                ],
                const SizedBox(height: 24),
                _MandatoryExpensesSection(
                  isPeriodic: isPeriodic,
                  expenses: isPeriodic
                      ? state.mandatoryExpenses
                      : state.todayMandatoryExpenses,
                  nameController: _expenseNameController,
                  amountController: _expenseAmountController,
                  nameError: _expenseNameError,
                  amountError: _expenseAmountError,
                  onAdd: () => _addExpense(isPeriodic),
                  onRemove: (idx) {
                    final notifier = ref.read(
                      payCycleTransitionNotifierProvider.notifier,
                    );
                    if (isPeriodic) {
                      notifier.removeMandatoryExpenseAt(idx);
                    } else {
                      notifier.removeTodayMandatoryExpenseAt(idx);
                    }
                  },
                ),
                const SizedBox(height: 32),
                _SubmitButton(state: state, referenceNow: widget.referenceNow),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.isPeriodic});

  final bool isPeriodic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPeriodic ? Icons.calendar_month : Icons.event_repeat,
                color: AppColors.brandTeal,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isPeriodic
                    ? l10n.payCycleTransitionHeaderPeriodicTitle
                    : l10n.payCycleTransitionHeaderDailyTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPeriodic
                ? l10n.payCycleTransitionHeaderPeriodicMessage
                : l10n.payCycleTransitionHeaderDailyMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeAIntervalAndDatePicker extends ConsumerWidget {
  const _ModeAIntervalAndDatePicker({
    required this.state,
    required this.referenceNow,
  });

  final PayCycleTransitionState state;
  final DateTime referenceNow;

  static String _formatDate(DateTime date) {
    try {
      return DateFormat('d MMMM y', 'id_ID').format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(payCycleTransitionNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.payCycleTransitionIntervalDateTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: IncomeIntervalType.values.map((type) {
            final selected = state.incomeIntervalType == type;
            return ChoiceChip(
              key: ValueKey('transition_interval_chip_${type.name}'),
              label: Text(_intervalLabel(l10n, type)),
              selected: selected,
              onSelected: (_) => notifier.setIncomeIntervalType(type),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const ValueKey('transition_payday_picker_button'),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  state.nextPaydayDate ??
                  referenceNow.add(const Duration(days: 30)),
              firstDate: referenceNow,
              lastDate: referenceNow.add(const Duration(days: 365 * 2)),
            );
            if (picked != null) {
              notifier.setNextPaydayDate(picked);
            }
          },
          icon: const Icon(Icons.calendar_today),
          label: Text(
            state.nextPaydayDate == null
                ? l10n.payCycleTransitionPickPaydayButton
                : l10n.payCycleTransitionPaydaySelectedButton(
                    _formatDate(state.nextPaydayDate!),
                  ),
          ),
        ),
      ],
    );
  }

  static String _intervalLabel(AppLocalizations l10n, IncomeIntervalType type) {
    switch (type) {
      case IncomeIntervalType.weekly:
        return l10n.payCycleTransitionIntervalWeekly;
      case IncomeIntervalType.biweekly:
        return l10n.payCycleTransitionIntervalBiweekly;
      case IncomeIntervalType.monthly:
        return l10n.payCycleTransitionIntervalMonthly;
      case IncomeIntervalType.custom:
        return l10n.payCycleTransitionIntervalCustom;
    }
  }
}

class _ModeASalaryInput extends StatelessWidget {
  const _ModeASalaryInput({
    required this.controller,
    required this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const ValueKey('transition_salary_field'),
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [RupiahInputFormatter()],
          decoration: InputDecoration(
            labelText: l10n.payCycleTransitionSalaryLabel,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixText: 'Rp ',
            errorText: errorText,
            helperText: l10n.payCycleTransitionSalaryHelper,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _ModeBCarryOverCard extends StatelessWidget {
  const _ModeBCarryOverCard({required this.carryOver});

  final int carryOver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPositive = carryOver >= 0;
    final amountColor = isPositive ? AppColors.brandTeal : AppColors.expenseRed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.payCycleTransitionCarryOverTitle,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            key: const ValueKey('transition_carry_over_display'),
            formatRupiah(carryOver),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.payCycleTransitionCarryOverMessage,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ModeBBekelInput extends StatelessWidget {
  const _ModeBBekelInput({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const ValueKey('transition_bekel_field'),
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [RupiahInputFormatter()],
          decoration: InputDecoration(
            labelText: l10n.payCycleTransitionBekelLabel,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixText: 'Rp ',
            helperText: l10n.payCycleTransitionBekelHelper,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _MandatoryExpensesSection extends StatelessWidget {
  const _MandatoryExpensesSection({
    required this.isPeriodic,
    required this.expenses,
    required this.nameController,
    required this.amountController,
    required this.nameError,
    required this.amountError,
    required this.onAdd,
    required this.onRemove,
  });

  final bool isPeriodic;
  final List<MandatoryExpenseItem> expenses;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final String? nameError;
  final String? amountError;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPeriodic
              ? l10n.payCycleTransitionExpensesPeriodicTitle
              : l10n.payCycleTransitionExpensesDailyTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.payCycleTransitionExpensesSubtitle,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (expenses.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              l10n.payCycleTransitionExpensesEmptyMessage,
              style: theme.textTheme.bodySmall,
            ),
          )
        else
          ...expenses.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Card(
              key: ValueKey('transition_expense_row_$index'),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(formatRupiah(item.amount)),
                trailing: IconButton(
                  key: ValueKey('transition_remove_expense_$index'),
                  tooltip: l10n.payCycleTransitionRemoveExpenseTooltip,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.expenseRed,
                  ),
                  onPressed: () => onRemove(index),
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('transition_expense_name_field'),
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.payCycleTransitionExpenseNameFieldLabel,
            errorText: nameError,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          key: const ValueKey('transition_expense_amount_field'),
          controller: amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [RupiahInputFormatter()],
          decoration: InputDecoration(
            labelText: l10n.payCycleTransitionExpenseAmountFieldLabel,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixText: 'Rp ',
            errorText: amountError,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          key: const ValueKey('transition_add_expense_button'),
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text(l10n.payCycleTransitionAddExpenseButton),
        ),
      ],
    );
  }
}

class _SubmitButton extends ConsumerWidget {
  const _SubmitButton({required this.state, this.referenceNow});

  final PayCycleTransitionState state;
  final DateTime? referenceNow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPeriodic = state.isPeriodic;
    final canSubmit = state.canSubmit;

    return FilledButton(
      key: const ValueKey('transition_submit_button'),
      onPressed: (!canSubmit || state.isSubmitting)
          ? null
          : () {
              ref
                  .read(payCycleTransitionNotifierProvider.notifier)
                  .submitTransition(referenceNow: referenceNow);
            },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: state.isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              isPeriodic
                  ? l10n.payCycleTransitionStartNewCycleButton
                  : l10n.payCycleTransitionStartTodayButton,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
    );
  }
}
