import 'package:flutter/material.dart';

import '../../transactions/presentation/transactions_screen.dart';

/// Post-onboarding placeholder. M2 scope is the Onboarding Wizard only —
/// the real dashboard/budget number is M4's "Smart Daily Budget Engine".
/// M3 connects transaction CRUD (FR-02, FR-03) through here so the user
/// can exercise add/edit/delete end to end.
class PlaceholderHomeScreen extends StatelessWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LedgerMate'),
        actions: [
          IconButton(
            key: const ValueKey('appbar_transactions_button'),
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Daftar Transaksi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TransactionsScreen()),
              );
            },
          ),
        ],
      ),
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
              const SizedBox(height: 32),
              FilledButton.icon(
                key: const ValueKey('open_transactions_button'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TransactionsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('Buka Daftar Transaksi (M3)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
