import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      _nameError = val.trim().isEmpty ? 'Nama dompet tidak boleh kosong' : null;
    });
  }

  void _onBalanceChanged(String val) {
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final parsed = parseRupiah(val) ?? 0;
    notifier.setWalletStartingBalance(parsed);
    setState(() {
      _balanceError = parsed < 0 ? 'Saldo awal tidak boleh negatif' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingWizardProvider);
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            stepIndex: 1,
            totalSteps: 4,
            title: 'Atur Dompet Pertamamu',
            subtitle:
                'Dompet tempat menyimpan uangmu (misal: Tunai, Rekening Bank, E-Wallet). '
                'Kamu bisa menambah dompet lain nanti.',
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const ValueKey('onboarding_wallet_name_field'),
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Dompet',
              hintText: 'Misal: Dompet Utama, Tunai, Rekening BCA',
              errorText: _nameError,
            ),
            onChanged: _onNameChanged,
          ),
          const SizedBox(height: 20),
          Text(
            'Pilih Ikon Dompet',
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
              labelText: 'Saldo Awal',
              prefixText: 'Rp ',
              hintText: '0',
              helperText: 'Saldo riil yang ada di dompet ini saat mulai menggunakan aplikasi.',
              errorText: _balanceError,
            ),
            onChanged: _onBalanceChanged,
          ),
          const SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              key: const ValueKey('onboarding_wallet_include_budget_switch'),
              title: const Text('Sertakan dalam Budget Harian'),
              subtitle: const Text(
                'Uang di dompet ini akan dihitung ke dalam Uang Jajan Aman Hari Ini (BR-04).',
              ),
              value: state.walletIncludeInDailyBudget,
              onChanged: notifier.setWalletIncludeInDailyBudget,
            ),
          ),
        ],
      ),
    );
  }
}
