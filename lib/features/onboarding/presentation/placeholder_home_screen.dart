import 'package:flutter/material.dart';

/// Post-onboarding placeholder. M2 scope is the Onboarding Wizard only —
/// the real dashboard/budget number is M4's "Smart Daily Budget Engine".
/// This just proves the gate works: reach here only once
/// `LocalProfile.onboardingComplete` is true.
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome, onboarding done',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Dashboard harian (Smart Daily Budget Engine) menyusul di M4.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
