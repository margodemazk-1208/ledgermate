import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/local_profile.dart';
import '../../application/onboarding_providers.dart';
import 'onboarding_step_header.dart';

/// Step (a): pick Income Frequency — Mode A "Periodik" (interval length +
/// next income date) or Mode B "Harian" (no date, just confirms the
/// mode). PRD FR-01 + §7.1 BR-01.
class IncomeFrequencyStep extends ConsumerWidget {
  const IncomeFrequencyStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingWizardProvider);
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingStepHeader(
            stepIndex: 0,
            totalSteps: 3,
            title: 'Pola Pendapatanmu',
            subtitle: 'Pilih yang paling cocok dengan cara kamu menerima uang.',
          ),
          _ModeCard(
            title: 'Periodik',
            description:
                'Gajian lump-sum di tanggal tertentu — mingguan, 2 mingguan, '
                'bulanan, atau custom.',
            selected: state.incomeFrequency == IncomeFrequency.periodic,
            onTap: () => notifier.selectFrequency(IncomeFrequency.periodic),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            title: 'Harian',
            description:
                'Bekel/income diterima tiap hari (termasuk jadwal nggak '
                'rata) — tanpa tanggal gajian tetap.',
            selected: state.incomeFrequency == IncomeFrequency.daily,
            onTap: () => notifier.selectFrequency(IncomeFrequency.daily),
          ),
          if (state.incomeFrequency == IncomeFrequency.periodic) ...[
            const SizedBox(height: 24),
            Text('Interval', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: IncomeIntervalType.values.map((type) {
                final selected = state.incomeIntervalType == type;
                return ChoiceChip(
                  key: ValueKey('interval_chip_${type.name}'),
                  label: Text(_intervalLabel(type)),
                  selected: selected,
                  onSelected: (_) => notifier.selectIntervalType(type),
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Tanggal income berikutnya',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('next_payday_picker_button'),
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: state.nextPaydayDate ?? now,
                  firstDate: now.subtract(const Duration(days: 1)),
                  lastDate: now.add(const Duration(days: 365 * 2)),
                );
                if (picked != null) {
                  notifier.setNextPaydayDate(picked);
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                state.nextPaydayDate == null
                    ? 'Pilih tanggal'
                    : DateFormat(
                        'd MMMM y',
                        'id_ID',
                      ).format(state.nextPaydayDate!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _intervalLabel(IncomeIntervalType type) {
    switch (type) {
      case IncomeIntervalType.weekly:
        return 'Mingguan';
      case IncomeIntervalType.biweekly:
        return '2 Mingguan';
      case IncomeIntervalType.monthly:
        return 'Bulanan';
      case IncomeIntervalType.custom:
        return 'Custom';
    }
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey('mode_card_${title.toLowerCase()}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.12),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
