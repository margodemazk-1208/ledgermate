import 'package:flutter/material.dart';

/// Shared step header: a 3-dot progress indicator + title/subtitle, reused
/// by all 3 onboarding steps so the wizard reads as one consistent flow
/// (docs/DESIGN.md "calm, precise" tone — no per-step visual drift).
class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
  });

  final int stepIndex;
  final int totalSteps;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(totalSteps, (i) {
            final isActive = i <= stepIndex;
            return Expanded(
              child: Container(
                key: ValueKey('onboarding_step_dot_$i'),
                margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 8),
                height: 4,
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        Text(title, style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(subtitle, style: textTheme.bodyMedium),
        const SizedBox(height: 24),
      ],
    );
  }
}
