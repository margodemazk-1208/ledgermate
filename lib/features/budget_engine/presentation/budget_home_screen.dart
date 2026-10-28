import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../transactions/presentation/transaction_form_screen.dart';
import '../../transactions/presentation/transactions_screen.dart';
import '../application/budget_providers.dart';

/// M4 Smart Daily Budget Engine Home Dashboard.
///
/// Identity motif (docs/DESIGN.md):
/// The daily safe-spend number ("Uang Jajan Aman Hari Ini") is ALWAYS the
/// single largest, boldest element on screen. Every other metric is
/// visually quieter.
class BudgetHomeScreen extends ConsumerWidget {
  const BudgetHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final budgetAsync = ref.watch(dailyBudgetSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LedgerMate'),
        actions: [
          IconButton(
            key: const ValueKey('theme_toggle_button'),
            tooltip: isDark
                ? 'Beralih ke mode terang'
                : 'Beralih ke mode gelap',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .set(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
          IconButton(
            key: const ValueKey('appbar_transactions_button'),
            tooltip: 'Riwayat Transaksi',
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TransactionsScreen()),
              );
            },
          ),
        ],
      ),
      body: budgetAsync.when(
        data: (summary) => _DashboardBody(summary: summary),
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: ValueKey('budget_loading_indicator'),
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
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
                  'Gagal memuat budget: $error',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add_transaction_fab'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Catat Transaksi'),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.summary});

  final DailyBudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = summary.isPositive;
    final focalColor = isPositive ? AppColors.brandTeal : AppColors.expenseRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      summary.incomeFrequency == IncomeFrequency.periodic
                          ? Icons.calendar_month
                          : Icons.account_balance_wallet,
                      size: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      summary.incomeFrequency == IncomeFrequency.periodic
                          ? 'Mode Periodik'
                          : 'Mode Harian (Bekel)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Focal Point Header: Uang Jajan Aman Hari Ini
          Text(
            'Uang Jajan Aman Hari Ini',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // THE FOCAL POINT NUMBER (docs/DESIGN.md identity motif)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              key: const ValueKey('daily_safe_spend_number'),
              formatRupiah(summary.uangJajanAmanHariIni),
              style: theme.textTheme.displayLarge?.copyWith(
                color: focalColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle context
          Text(_subtitleText(summary), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 32),

          // Breakdown card
          _BreakdownCard(summary: summary),
          const SizedBox(height: 20),

          // Quick link to full transactions
          OutlinedButton.icon(
            key: const ValueKey('view_transactions_button'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TransactionsScreen()),
              );
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('Lihat Riwayat Transaksi'),
          ),
          const SizedBox(height: 60), // Room for extended FAB
        ],
      ),
    );
  }

  static String _subtitleText(DailyBudgetSummary summary) {
    if (summary.incomeFrequency == IncomeFrequency.periodic &&
        summary.modeA != null) {
      final days = summary.modeA!.remainingDays;
      return 'Sisa $days hari sampai jadwal payday berikutnya';
    } else if (summary.modeB != null) {
      return 'Akumulasi carry-over kemarin & bekel hari ini';
    }
    return '';
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.summary});

  final DailyBudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modeA = summary.modeA;
    final modeB = summary.modeB;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rincian Perhitungan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (modeA != null) ...[
              _MetricRow(
                label: 'Sisa Saldo Siklus',
                value: formatRupiah(modeA.remainingBalance),
              ),
              const Divider(height: 20),
              _MetricRow(
                label: 'Jatah Kotor / Hari',
                value: formatRupiah(modeA.dailySpendingAllowance),
              ),
              const Divider(height: 20),
              _MetricRow(
                label: 'Tabungan Goal / Hari',
                value: '- ${formatRupiah(modeA.dailySavingsReserve)}',
                valueColor: modeA.dailySavingsReserve > 0
                    ? AppColors.savingsGreen
                    : null,
              ),
            ] else if (modeB != null) ...[
              _MetricRow(
                label: 'Saldo Carry-Over Kemarin',
                value: formatRupiah(modeB.saldoCarryOver),
              ),
              const Divider(height: 20),
              _MetricRow(
                label: 'Bekel Masuk Hari Ini',
                value: '+ ${formatRupiah(modeB.bekelHariIni)}',
              ),
              const Divider(height: 20),
              _MetricRow(
                label: 'Pengeluaran Wajib Hari Ini',
                value: '- ${formatRupiah(modeB.pengeluaranWajibHariIni)}',
              ),
              const Divider(height: 20),
              _MetricRow(
                label: 'Pengeluaran Dicatat Hari Ini',
                value: '- ${formatRupiah(modeB.pengeluaranHariIni)}',
                valueColor: modeB.pengeluaranHariIni > 0
                    ? AppColors.expenseRed
                    : null,
              ),
              const Divider(height: 20),
              _MetricRow(
                label: 'Tabungan Goal / Hari',
                value: '- ${formatRupiah(modeB.dailySavingsReserve)}',
                valueColor: modeB.dailySavingsReserve > 0
                    ? AppColors.savingsGreen
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
