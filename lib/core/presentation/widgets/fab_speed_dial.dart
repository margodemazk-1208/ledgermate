import 'package:flutter/material.dart';

import '../../database/transaction.dart' as db;
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../features/assets/presentation/asset_form_screen.dart';
import '../../../features/goals/presentation/goal_form_screen.dart';
import '../../../features/transactions/presentation/transaction_form_screen.dart';
import '../../../features/wallets/presentation/transfer_form_screen.dart';

/// Home's FAB speed-dial per `docs/design/mockups/08_fab_overlay.html`.
///
/// Per the M13 task scope this delivers the STATIC visual state only (dimmed
/// background, 5 stacked options bottom-to-top, FAB rotated 45° to an "X")
/// — the staggered reveal/collapse animation is M14's job
/// (`docs/DESIGN.md` §Motion), so the overlay is shown/hidden instantly here
/// (`transitionDuration: Duration.zero`).
class FabSpeedDial extends StatelessWidget {
  const FabSpeedDial({super.key});

  Future<void> _open(BuildContext context) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, _) => const _SpeedDialOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const ValueKey('home_fab_speed_dial'),
      onPressed: () => _open(context),
      child: const Icon(Icons.add),
    );
  }
}

class _SpeedDialOverlay extends StatelessWidget {
  const _SpeedDialOverlay();

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop(); // close overlay first
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Tap-anywhere-to-dismiss scrim (the barrier itself already does
          // this via barrierDismissible, this just gives the FAB area a
          // dedicated close target matching the mockup's rotated-X affordance).
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          Positioned(
            right: 20,
            bottom: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SpeedDialOption(
                  key: const ValueKey('fab_option_add_asset'),
                  label: 'Tambah Aset Baru',
                  icon: Icons.account_balance_outlined,
                  dark: true,
                  onTap: () => _openScreen(context, const AssetFormScreen()),
                ),
                const SizedBox(height: 14),
                _SpeedDialOption(
                  key: const ValueKey('fab_option_add_goal'),
                  label: 'Tambah Goal Baru',
                  icon: Icons.track_changes_outlined,
                  dark: true,
                  onTap: () => _openScreen(context, const GoalFormScreen()),
                ),
                const SizedBox(height: 14),
                _SpeedDialOption(
                  key: const ValueKey('fab_option_transfer'),
                  label: 'Transfer Antar Dompet',
                  icon: Icons.swap_horiz,
                  dark: true,
                  onTap: () => _openScreen(context, const TransferFormScreen()),
                ),
                const SizedBox(height: 14),
                _SpeedDialOption(
                  key: const ValueKey('fab_option_income'),
                  label: 'Catat Pemasukan',
                  icon: Icons.arrow_upward,
                  dark: false,
                  onTap: () => _openScreen(
                    context,
                    const TransactionFormScreen(
                      initialType: db.TransactionType.income,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _SpeedDialOption(
                  key: const ValueKey('fab_option_expense'),
                  label: 'Catat Pengeluaran',
                  icon: Icons.arrow_downward,
                  dark: false,
                  onTap: () => _openScreen(
                    context,
                    const TransactionFormScreen(
                      initialType: db.TransactionType.expense,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Rotated FAB-to-X: same slot the real FAB occupies, closes
                // the overlay on tap (static visual only, per scope).
                FloatingActionButton(
                  key: const ValueKey('home_fab_speed_dial_close'),
                  heroTag: 'fab_speed_dial_close',
                  onPressed: () => Navigator.of(context).pop(),
                  child: Transform.rotate(
                    angle: 0.785398, // 45 degrees
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedDialOption extends StatelessWidget {
  const _SpeedDialOption({
    super.key,
    required this.label,
    required this.icon,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final IconData icon;

  /// Mockup alternates dark pill+badge (Aset/Goal/Transfer) and light
  /// pill+badge (Pemasukan/Pengeluaran, the two most-used quick actions).
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pillBg = dark ? const Color(0xFF1E1E1E) : AppColors.whitePill;
    final fg = dark ? Colors.white : const Color(0xFF121212);
    final badgeBg = dark ? const Color(0xFF262626) : AppColors.whitePill;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(999),
              border: dark
                  ? Border.all(color: Theme.of(context).dividerColor)
                  : null,
            ),
            child: Text(
              label,
              style: AppTypography.mono(
                fontSize: 12,
                fontWeight: dark ? FontWeight.w400 : FontWeight.w700,
                color: fg,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badgeBg,
              shape: BoxShape.circle,
              border: dark
                  ? Border.all(color: Theme.of(context).dividerColor)
                  : null,
            ),
            child: Icon(icon, size: 18, color: fg),
          ),
        ],
      ),
    );
  }
}
