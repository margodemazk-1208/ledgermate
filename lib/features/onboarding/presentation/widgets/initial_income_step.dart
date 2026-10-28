import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/local_profile.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../application/onboarding_providers.dart';
import 'onboarding_step_header.dart';

/// Step (b): input initial income amount. Label/helper text adapt to the
/// mode picked in step (a) — Mode A frames it as the fixed salary for
/// this pay cycle, Mode B frames it as today's starting buffer (seeds
/// `LocalProfile.carryOverBalance`, see `onboarding_repository.dart`).
class InitialIncomeStep extends ConsumerStatefulWidget {
  const InitialIncomeStep({super.key});

  @override
  ConsumerState<InitialIncomeStep> createState() => _InitialIncomeStepState();
}

class _InitialIncomeStepState extends ConsumerState<InitialIncomeStep> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(onboardingWizardProvider).initialIncomeAmount;
    _controller = TextEditingController(
      text: existing == null
          ? ''
          : formatRupiah(existing).replaceAll('Rp ', ''),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final parsed = parseRupiah(value);
    notifier.setInitialIncomeAmount(parsed);
    setState(() {
      _errorText = validateRupiahAmount(
        value,
        emptyMessage: 'Jumlah tidak boleh kosong',
        invalidMessage: 'Jumlah tidak boleh negatif atau nol',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPeriodic =
        ref.watch(onboardingWizardProvider.select((s) => s.incomeFrequency)) ==
        IncomeFrequency.periodic;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingStepHeader(
            stepIndex: 1,
            totalSteps: 3,
            title: isPeriodic ? 'Gaji Siklus Ini' : 'Bekel Awal Hari Ini',
            subtitle: isPeriodic
                ? 'Masukkan total gaji tetap untuk siklus gajian ini.'
                : 'Masukkan uang yang sudah kamu pegang untuk mulai hari ini.',
          ),
          TextField(
            key: const ValueKey('initial_income_field'),
            controller: _controller,
            onChanged: _onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [RupiahInputFormatter()],
            decoration: InputDecoration(
              labelText: isPeriodic ? 'Gaji tetap' : 'Jumlah awal',
              prefixText: 'Rp ',
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
