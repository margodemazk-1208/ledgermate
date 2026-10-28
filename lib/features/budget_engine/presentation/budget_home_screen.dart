import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_profile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../assets/presentation/assets_screen.dart';
import '../../goals/presentation/goals_screen.dart';
import '../../pay_cycle/presentation/pay_cycle_transition_screen.dart';
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
            key: const ValueKey('appbar_goals_button'),
            tooltip: 'Target Tabungan',
            icon: const Icon(Icons.flag_outlined),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const GoalsScreen()));
            },
          ),
          IconButton(
            key: const ValueKey('appbar_assets_button'),
            tooltip: 'Aset & Investasi',
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AssetsScreen()));
            },
          ),
          IconButton(
            key: const ValueKey('appbar_analytics_button'),
            tooltip: 'Visual Analitik',
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
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
      bottomNavigationBar: BottomNavigationBar(
        key: const ValueKey('budget_home_bottom_nav_bar'),
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.brandTeal,
        unselectedItemColor: theme.textTheme.bodySmall?.color?.withValues(
          alpha: 0.6,
        ),
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TransactionsScreen()),
              );
              break;
            case 2:
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const GoalsScreen()));
              break;
            case 3:
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AssetsScreen()));
              break;
            case 4:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
              break;
            case 5:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur Pengaturan akan hadir di Milestone 10.'),
                ),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Aset',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Analitik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
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
          if (summary.isCycleExpired) ...[
            const SizedBox(height: 16),
            Container(
              key: const ValueKey('cycle_transition_banner'),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.expenseRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.expenseRed.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.expenseRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summary.incomeFrequency == IncomeFrequency.periodic
                              ? 'Siklus Gajian Berakhir'
                              : 'Rollover Harian Dibutuhkan',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.expenseRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    summary.incomeFrequency == IncomeFrequency.periodic
                        ? 'Jadwal gajian telah tercapai. Mulai siklus baru untuk memperbarui Uang Jajan Aman.'
                        : 'Hari baru telah tiba. Konfirmasi carry-over saldo untuk memulai hari ini.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const ValueKey('cycle_transition_button'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PayCycleTransitionScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.expenseRed,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text(
                      summary.incomeFrequency == IncomeFrequency.periodic
                          ? 'Mulai Siklus Baru'
                          : 'Rollover Hari Ini',
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('view_goals_button'),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const GoalsScreen()));
            },
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Kelola Target Tabungan'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('view_assets_button'),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AssetsScreen()));
            },
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text('Kelola Aset & Investasi'),
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
