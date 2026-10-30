import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/local_profile.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/presentation/navigation/app_shell.dart';
import '../../../core/presentation/navigation/slide_page_route.dart';
import '../../../core/presentation/widgets/app_bottom_nav.dart';
import '../../../core/presentation/widgets/count_up_rupiah.dart';
import '../../../core/presentation/widgets/fab_speed_dial.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../../pay_cycle/presentation/pay_cycle_transition_screen.dart';
import '../../transactions/application/transaction_providers.dart';
import '../../wallets/application/wallet_providers.dart';
import '../../wallets/utils/wallet_icons.dart';
import '../application/budget_providers.dart';

/// M4 Smart Daily Budget Engine Home Dashboard.
///
/// Visuals rebuilt for M13 (v1.2) per `docs/design/mockups/renders/00_*`/`01_*`
/// (the only screen without a dedicated clean HTML mockup — judgment call
/// derived from the two Figma sketches + the shared `style.css` token system).
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
    final budgetAsync = ref.watch(dailyBudgetSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('LedgerMate', style: AppTypography.script(fontSize: 22)),
            Text(
              DateFormat('EEEE: dd-MMM-yy', 'id_ID').format(DateTime.now()),
              style: AppTypography.mono(
                fontSize: 11,
                color: theme.textTheme.bodySmall?.color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
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
      floatingActionButton: const FabSpeedDial(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.summary});

  final DailyBudgetSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPositive = summary.isPositive;
    final focalColor = isPositive ? AppColors.burgundy : AppColors.expenseRed;

    final totalSaldoAsync = ref.watch(totalSaldoProvider);
    final walletsAsync = ref.watch(walletsStreamProvider);
    final balances =
        ref.watch(walletBalancesProvider).value ?? const <int, int>{};

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
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
                  border: Border.all(color: theme.dividerColor),
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
                      style: AppTypography.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (summary.isCycleExpired) ...[
            const SizedBox(height: 16),
            _CycleTransitionBanner(summary: summary),
          ],
          const SizedBox(height: 20),

          // Total Saldo card (net worth across all wallets, FR-12/D16)
          _SimpleValueCard(
            key: const ValueKey('home_total_saldo_card'),
            label: 'Total Saldo',
            value: formatRupiah(totalSaldoAsync.value ?? 0),
          ),
          const SizedBox(height: 16),

          // Per-wallet balance cards (M12 Wallet data — fully user-defined,
          // not fixed Tunai/E-Wallet/Bank types per D16).
          walletsAsync.when(
            data: (wallets) => wallets.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 84,
                    child: ListView.separated(
                      key: const ValueKey('home_wallet_cards_row'),
                      scrollDirection: Axis.horizontal,
                      itemCount: wallets.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final w = wallets[i];
                        return _WalletMiniCard(
                          name: w.name,
                          icon: getWalletIcon(w.icon),
                          balance: balances[w.id] ?? w.startingBalance,
                        );
                      },
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),

          // Focal Point: Uang Jajan Aman Hari Ini (identity motif)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jatah Hari Ini',
                  style: AppTypography.mono(
                    fontSize: 13,
                    letterSpacing: 0.5,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: CountUpRupiah(
                    textKey: const ValueKey('daily_safe_spend_number'),
                    value: summary.uangJajanAmanHariIni,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: focalColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(_subtitleText(summary), style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Breakdown card
          _BreakdownCard(summary: summary),
          const SizedBox(height: 20),

          // Rincian Transaksi preview (nominal-only, per clarified minimalism)
          const _RincianTransaksiCard(),
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

class _CycleTransitionBanner extends StatelessWidget {
  const _CycleTransitionBanner({required this.summary});

  final DailyBudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('cycle_transition_banner'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.expenseRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.expenseRed.withValues(alpha: 0.4)),
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
                SlidePageRoute(
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
    );
  }
}

/// `.card .card-row` pattern per style.css — label left, bold value right.
class _SimpleValueCard extends StatelessWidget {
  const _SimpleValueCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.mono(
              fontSize: 13,
              letterSpacing: 0.5,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          Text(
            value,
            style: AppTypography.mono(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletMiniCard extends StatelessWidget {
  const _WalletMiniCard({
    required this.name,
    required this.icon,
    required this.balance,
  });

  final String name;
  final IconData icon;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2E2E2E)
                      : const Color(0xFFEBEBEA),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 13),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            formatRupiah(balance),
            overflow: TextOverflow.ellipsis,
            style: AppTypography.mono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Perhitungan',
            style: AppTypography.script(fontSize: 16),
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
          style: AppTypography.mono(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

/// Rincian Transaksi preview per `renders/01_*`: Pemasukan / Pengeluaran
/// columns, nominal-only rows (no description/date — deliberate minimalism),
/// "Lihat Selengkapnya" deep-links to the full Transaksi list.
class _RincianTransaksiCard extends ConsumerWidget {
  const _RincianTransaksiCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final txsAsync = ref.watch(transactionsStreamProvider);
    final txs = txsAsync.value ?? const <db.Transaction>[];

    final income = txs
        .where((t) => t.type == db.TransactionType.income)
        .take(3)
        .toList();
    final expense = txs
        .where((t) => t.type == db.TransactionType.expense)
        .take(3)
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rincian Transaksi',
                style: AppTypography.script(fontSize: 16),
              ),
              InkWell(
                key: const ValueKey('home_view_all_transactions_link'),
                onTap: () {
                  // M18/D18 perf item 5: switch the shared shell tab
                  // instead of pushing a second, independently-provider-
                  // watching `TransactionsScreen` instance on top of it.
                  ref.read(currentTabIndexProvider.notifier).setIndex(1);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Selengkapnya',
                      style: AppTypography.mono(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (txsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (txsAsync.hasError)
            Text(
              'Gagal memuat ringkasan transaksi.',
              style: theme.textTheme.bodySmall,
            )
          else if (txs.isEmpty)
            Text(
              'Belum ada transaksi tercatat.',
              style: theme.textTheme.bodySmall,
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _RincianColumn(
                    label: 'Pemasukan',
                    amounts: income.map((t) => t.amount).toList(),
                    color: AppColors.savingsGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RincianColumn(
                    label: 'Pengeluaran',
                    amounts: expense.map((t) => t.amount).toList(),
                    color: AppColors.expenseRed,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RincianColumn extends StatelessWidget {
  const _RincianColumn({
    required this.label,
    required this.amounts,
    required this.color,
  });

  final String label;
  final List<int> amounts;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.whitePill,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTypography.mono(
              fontSize: 11,
              color: const Color(0xFF15150F),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (amounts.isEmpty)
          Text('Belum ada', style: theme.textTheme.bodySmall)
        else
          for (var i = 0; i < amounts.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == amounts.length - 1 ? 0 : 8),
              child: Text(
                formatRupiah(amounts[i]),
                style: AppTypography.mono(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
      ],
    );
  }
}
