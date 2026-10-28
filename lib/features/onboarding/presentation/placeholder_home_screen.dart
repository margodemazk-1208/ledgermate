import 'package:flutter/material.dart';

/// Milestone-0 placeholder: proves the theme renders in both modes.
/// Replaced by the real onboarding/home flow in M2 (FR-01).
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'LedgerMate',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
