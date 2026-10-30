import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../../wallets/utils/wallet_icons.dart';
import '../../application/onboarding_providers.dart';
import 'onboarding_step_header.dart';

/// Step (b): setup first wallet (v1.1 FR-01, FR-12, BR-04).
class WalletSetupStep extends ConsumerStatefulWidget {
  const WalletSetupStep({super.key});

  @override
  ConsumerState<WalletSetupStep> createState() => _WalletSetupStepState();
}

class _WalletSetupStepState extends ConsumerState<WalletSetupStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  String? _nameError;
  String? _balanceError;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingWizardProvider);
    _nameController = TextEditingController(text: state.walletName);
    _balanceController = TextEditingController(
      text: state.walletStartingBalance == 0
          ? '0'
          : formatRupiah(state.walletStartingBalance).replaceAll('Rp ', ''),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _onNameChanged(String val) {
    final notifier = ref.read(onboardingWizardProvider.notifier);
    notifier.setWalletName(val);
    setState(() {
      _nameError = val.trim().isEmpty
          ? AppLocalizations.of(context)!.walletSetupStepNameEmptyError
          : null;
    });
  }

  void _onBalanceChanged(String val) {
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final parsed = parseRupiah(val) ?? 0;
    notifier.setWalletStartingBalance(parsed);
    setState(() {
      _balanceError = parsed < 0
          ? AppLocalizations.of(context)!.walletSetupStepNegativeBalanceError
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(onboardingWizardProvider);
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingStepHeader(
            stepIndex: 1,
            totalSteps: 4,
            title: l10n.walletSetupStepTitle,
            subtitle: l10n.walletSetupStepSubtitle,
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const ValueKey('onboarding_wallet_name_field'),
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.walletSetupStepNameFieldLabel,
              hintText: l10n.walletSetupStepNameFieldHint,
              errorText: _nameError,
            ),
            onChanged: _onNameChanged,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.walletSetupStepIconPickerLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          SizedBox(
            key: const ValueKey('onboarding_wallet_icon_picker'),
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: supportedWalletIcons.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = supportedWalletIcons[index];
                final isSelected = item.key == state.walletIcon;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => notifier.setWalletIcon(item.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            key: const ValueKey('onboarding_wallet_starting_balance_field'),
            controller: _balanceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.walletSetupStepStartingBalanceLabel,
              prefixText: 'Rp ',
              hintText: '0',
              helperText: l10n.walletSetupStepStartingBalanceHelper,
              errorText: _balanceError,
            ),
            onChanged: _onBalanceChanged,
          ),
          const SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              key: const ValueKey('onboarding_wallet_include_budget_switch'),
              title: Text(l10n.walletSetupStepIncludeBudgetTitle),
              subtitle: Text(l10n.walletSetupStepIncludeBudgetSubtitle),
              value: state.walletIncludeInDailyBudget,
              onChanged: notifier.setWalletIncludeInDailyBudget,
            ),
          ),
        ],
      ),
    );
  }
}
