// Create and edit form for FinancialGoal with Realism Warning check (FR-06, FR-06b, BR-03).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/financial_goal.dart';
import '../../../core/formulas/daily_budget_formulas.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/widgets/press_scale.dart';
import '../../../core/presentation/widgets/success_toast.dart';
import '../../../core/presentation/widgets/unsaved_changes_guard.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../budget_engine/application/budget_providers.dart';
import '../../wallets/application/wallet_providers.dart';
import '../application/goals_providers.dart';
import 'widgets/realism_warning_dialog.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key, this.goal});

  final FinancialGoal? goal;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetAmountController;
  late final TextEditingController _currentAmountController;
  late final TextEditingController _manualAllocationController;

  late DateTime _targetDate;
  late bool _hasManualAllocation;
  // D18/M17 bug #8: `_isBusy` guards re-entrancy across the WHOLE flow
  // (including the realism-warning `showDialog` await below) and disables
  // the button; `_isSubmitting` is purely visual (drives the spinner) and
  // is only ever true during the actual async `saveGoal` write — kept
  // separate so an indeterminate spinner isn't animating underneath the
  // realism dialog for its whole duration (that previously hung
  // `pumpAndSettle` in widget tests).
  bool _isBusy = false;
  bool _isSubmitting = false;
  String? _formError;

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
    final g = widget.goal;
    _nameController = TextEditingController(text: g?.goalName ?? '');
    // M19/D18: Rupiah fields now follow the SAME canonical pattern as
    // every other form in the app (transaction/asset/wallet) —
    // `RupiahInputFormatter` on the controller + a separate `prefixText:
    // 'Rp '` in the decoration — instead of embedding "Rp" into the
    // controller text itself via a manual onChanged re-format, which was
    // the one form in the app doing it differently.
    _targetAmountController = TextEditingController(
      text: g != null && g.targetAmount > 0
          ? _groupedDigits(g.targetAmount)
          : '',
    );
    _currentAmountController = TextEditingController(
      text: g != null && g.currentAmount > 0
          ? _groupedDigits(g.currentAmount)
          : '0',
    );
    _targetDate = g?.targetDate ?? DateTime.now().add(const Duration(days: 30));
    _hasManualAllocation = g?.manualDailyAllocation != null;
    _manualAllocationController = TextEditingController(
      text: g?.manualDailyAllocation != null
          ? _groupedDigits(g!.manualDailyAllocation!)
          : '',
    );
    _nameController.addListener(_markDirty);
    _targetAmountController.addListener(_markDirty);
    _currentAmountController.addListener(_markDirty);
    _manualAllocationController.addListener(_markDirty);
  }

  /// `formatRupiah` without the "Rp " prefix — the prefix now lives in
  /// each field's `InputDecoration.prefixText` instead (canonical pattern,
  /// matches transaction/asset/wallet forms).
  static String _groupedDigits(int amount) =>
      formatRupiah(amount).replaceFirst('Rp ', '');

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _manualAllocationController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate.isAfter(now)
          ? _targetDate
          : now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 15),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
      _markDirty();
    }
  }

  Future<void> _handleSave() async {
    // D18/M17 bug #8: entry guard BEFORE any async work (including the
    // realism-warning `showDialog` below) — a double-tap landing before
    // `_isBusy` flips true and the button visually disables would
    // otherwise race through validation+realism-check twice and save the
    // goal twice.
    if (_isBusy) return;
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    final name = _nameController.text.trim();
    final targetAmount = parseRupiah(_targetAmountController.text) ?? 0;
    final currentAmount = parseRupiah(_currentAmountController.text) ?? 0;
    final manualAlloc = _hasManualAllocation
        ? parseRupiah(_manualAllocationController.text)
        : null;

    if (targetAmount <= 0) {
      setState(() => _formError = l10n.goalFormScreenTargetAmountRequiredError);
      return;
    }

    final now = DateTime.now();
    if (!normalizeDate(_targetDate).isAfter(normalizeDate(now))) {
      setState(() => _formError = l10n.goalFormScreenTargetDateError);
      return;
    }

    final candidateGoal = FinancialGoal()
      ..id = widget.goal?.id ?? 0
      ..goalName = name
      ..targetAmount = targetAmount
      ..currentAmount = currentAmount
      ..targetDate = _targetDate
      ..manualDailyAllocation = manualAlloc;

    setState(() {
      _isBusy = true;
      _formError = null;
    });

    // Check realism against M4 budget engine (FR-06b, BR-03)
    final profile = ref.read(budgetProfileStreamProvider).value;
    final latestCycle = ref.read(budgetLatestPayCycleStreamProvider).value;
    final txs = ref.read(budgetTransactionsStreamProvider).value ?? const [];
    final existingGoals = ref.read(budgetGoalsStreamProvider).value ?? const [];
    final wallets = ref.read(walletsStreamProvider).value ?? const [];

    if (profile != null) {
      final realism = checkGoalRealism(
        candidateGoal: candidateGoal,
        existingGoals: existingGoals,
        profile: profile,
        latestCycle: latestCycle,
        transactions: txs,
        wallets: wallets,
        referenceNow: now,
      );

      if (realism.isUnrealistic) {
        final action = await showDialog<RealismWarningAction>(
          context: context,
          builder: (_) => RealismWarningDialog(
            projectedUangJajanAman: realism.projectedUangJajanAmanHariIni,
            projectedDailyReserve: realism.projectedDailySavingsReserve,
          ),
        );

        if (action == RealismWarningAction.extendDate) {
          // Action 1: "Perpanjang tanggal target"
          setState(() => _isBusy = false);
          await _pickTargetDate();
          return;
        } else if (action != RealismWarningAction.proceed) {
          // Dismissed dialog without picking proceed
          setState(() => _isBusy = false);
          return;
        }
        // Action 2: "Lanjut, saya paham risikonya" -> proceed to save
      }
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(goalsRepositoryProvider)
          .saveGoal(
            id: widget.goal?.id,
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            targetDate: _targetDate,
            manualDailyAllocation: manualAlloc,
          );
      if (mounted) {
        showSuccessToast(context, l10n.goalFormScreenSaveSuccessToast);
        _dirty = false;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _isSubmitting = false;
          _formError = l10n.goalFormScreenSaveError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.goal != null;
    final dateText = DateFormat('d MMMM yyyy', 'id_ID').format(_targetDate);

    return UnsavedChangesGuard(
      isDirty: () => _dirty,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing
                ? l10n.goalFormScreenEditTitle
                : l10n.goalFormScreenAddTitle,
            style: AppTypography.script(fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Goal Name
                TextFormField(
                  key: const ValueKey('goal_name_field'),
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.goalFormScreenNameLabel,
                    hintText: l10n.goalFormScreenNameHint,
                    prefixIcon: const Icon(Icons.flag_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n.goalFormScreenNameEmptyError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Target Amount
                TextFormField(
                  key: const ValueKey('goal_target_amount_field'),
                  controller: _targetAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  decoration: InputDecoration(
                    labelText: l10n.goalFormScreenTargetAmountLabel,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixText: 'Rp ',
                    hintText: '0',
                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (val) {
                    final parsed = parseRupiah(val ?? '');
                    if (parsed == null || parsed <= 0) {
                      return l10n.goalFormScreenTargetAmountError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Current Amount
                TextFormField(
                  key: const ValueKey('goal_current_amount_field'),
                  controller: _currentAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  decoration: InputDecoration(
                    labelText: l10n.goalFormScreenCurrentAmountLabel,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixText: 'Rp ',
                    hintText: '0',
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                    helperText: l10n.goalFormScreenCurrentAmountHelper,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (val) {
                    final parsed = parseRupiah(val ?? '');
                    if (parsed == null || parsed < 0) {
                      return l10n.goalFormScreenCurrentAmountNegativeError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Target Date Picker Tile
                ListTile(
                  key: const ValueKey('goal_target_date_tile'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  leading: const Icon(
                    Icons.calendar_today,
                    color: AppColors.brandTeal,
                  ),
                  title: Text(l10n.goalFormScreenTargetDateTitle),
                  subtitle: Text(
                    dateText,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.burgundyText(theme.brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _pickTargetDate,
                ),
                const SizedBox(height: 20),

                // Manual Daily Allocation Override (BR-03)
                SwitchListTile(
                  key: const ValueKey('goal_manual_allocation_switch'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.goalFormScreenManualAllocationTitle),
                  subtitle: Text(l10n.goalFormScreenManualAllocationSubtitle),
                  value: _hasManualAllocation,
                  activeTrackColor: AppColors.brandTeal,
                  onChanged: (enabled) {
                    setState(() {
                      _hasManualAllocation = enabled;
                    });
                    _markDirty();
                  },
                ),
                if (_hasManualAllocation) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const ValueKey('goal_manual_allocation_field'),
                    controller: _manualAllocationController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RupiahInputFormatter()],
                    decoration: InputDecoration(
                      labelText: l10n.goalFormScreenManualAllocationFieldLabel,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixText: 'Rp ',
                      hintText: '0',
                      prefixIcon: const Icon(Icons.tune),
                      helperText: l10n.goalFormScreenManualAllocationHelper,
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      if (!_hasManualAllocation) return null;
                      final parsed = parseRupiah(val ?? '');
                      if (parsed == null || parsed <= 0) {
                        return l10n.goalFormScreenManualAllocationError;
                      }
                      return null;
                    },
                  ),
                ],

                if (_formError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.expenseRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.expenseRed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _formError!,
                      style: TextStyle(
                        color: AppColors.expenseRedText(theme.brightness),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),

                // Submit Button
                PressScale(
                  enabled: !_isBusy,
                  child: FilledButton(
                    key: const ValueKey('save_goal_button'),
                    onPressed: _isBusy ? null : _handleSave,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.brandTeal,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditing
                                ? l10n.goalFormScreenUpdateButton
                                : l10n.goalFormScreenSaveButton,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
