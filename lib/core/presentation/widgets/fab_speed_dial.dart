import 'package:flutter/material.dart';

import '../../database/transaction.dart' as db;
import '../../motion/motion_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../navigation/slide_page_route.dart';
import 'press_scale.dart';
import '../../../features/assets/presentation/asset_form_screen.dart';
import '../../../features/goals/presentation/goal_form_screen.dart';
import '../../../features/transactions/presentation/transaction_form_screen.dart';
import '../../../features/wallets/presentation/transfer_form_screen.dart';

/// Home's FAB speed-dial per `docs/design/mockups/08_fab_overlay.html`,
/// with the M14 motion treatment from `docs/DESIGN.md` §Motion touchpoint 4:
/// staggered bottom-to-top reveal (Pengeluaran -> Pemasukan -> Transfer ->
/// Goal -> Aset), ~50ms stagger, each item fade+scale (0.8->1.0), FAB icon
/// rotates 45° (+ -> ×) over the same duration. Closing reverses the
/// stagger (top-to-bottom collapse) via the SAME `AnimationController` run
/// in reverse — see `_SpeedDialOverlay` doc comment for why that alone
/// produces the correct reverse ordering.
class FabSpeedDial extends StatelessWidget {
  const FabSpeedDial({super.key});

  Future<void> _open(BuildContext context) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, _) => const _SpeedDialOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: FloatingActionButton(
        key: const ValueKey('home_fab_speed_dial'),
        onPressed: () => _open(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SpeedDialOverlay extends StatefulWidget {
  const _SpeedDialOverlay();

  @override
  State<_SpeedDialOverlay> createState() => _SpeedDialOverlayState();
}

class _SpeedDialOverlayState extends State<_SpeedDialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionDurations.fabSpeedDial,
  );
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _controller.duration = motionDuration(
        context,
        MotionDurations.fabSpeedDial,
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Reverses the stagger (top-to-bottom collapse — see class doc comment
  /// on [FabSpeedDial]) before popping, so closing never hard-cuts.
  Future<void> _close() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Selecting an action dismisses the dial immediately and navigates —
  /// unlike explicit close (tap FAB/barrier), this isn't "closing the
  /// dial", it's "leaving it for another screen", so no collapse wait.
  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(SlidePageRoute(builder: (_) => screen));
  }

  /// Per-item reveal [Interval] within the shared controller's timeline,
  /// bottom-to-top on open (index 0 starts first) — reversing the same
  /// controller naturally collapses top-to-bottom (the last-revealed item,
  /// index 4, has the LATEST interval so it's first to fade out as the
  /// controller value decreases back through it).
  Interval _intervalFor(int index) {
    const stagger = 0.111; // ~50ms of the 450ms total duration
    const itemSpan = 0.555; // ~250ms fade/scale span
    final start = (index * stagger).clamp(0.0, 1.0);
    final end = (start + itemSpan).clamp(0.0, 1.0);
    return Interval(start, end, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Tap-anywhere-to-dismiss scrim (the barrier itself is now
          // non-dismissible so every close path plays the collapse anim).
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.opaque,
            ),
          ),
          Positioned(
            right: 20,
            bottom: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StaggeredItem(
                  animation: CurvedAnimation(
                    parent: _controller,
                    curve: _intervalFor(4),
                  ),
                  child: _SpeedDialOption(
                    key: const ValueKey('fab_option_add_asset'),
                    label: 'Tambah Aset Baru',
                    icon: Icons.account_balance_outlined,
                    dark: true,
                    onTap: () => _openScreen(context, const AssetFormScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                _StaggeredItem(
                  animation: CurvedAnimation(
                    parent: _controller,
                    curve: _intervalFor(3),
                  ),
                  child: _SpeedDialOption(
                    key: const ValueKey('fab_option_add_goal'),
                    label: 'Tambah Goal Baru',
                    icon: Icons.track_changes_outlined,
                    dark: true,
                    onTap: () => _openScreen(context, const GoalFormScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                _StaggeredItem(
                  animation: CurvedAnimation(
                    parent: _controller,
                    curve: _intervalFor(2),
                  ),
                  child: _SpeedDialOption(
                    key: const ValueKey('fab_option_transfer'),
                    label: 'Transfer Antar Dompet',
                    icon: Icons.swap_horiz,
                    dark: true,
                    onTap: () =>
                        _openScreen(context, const TransferFormScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                _StaggeredItem(
                  animation: CurvedAnimation(
                    parent: _controller,
                    curve: _intervalFor(1),
                  ),
                  child: _SpeedDialOption(
                    key: const ValueKey('fab_option_income'),
                    label: 'Catat Pemasukan',
                    // M19: was `arrow_upward`, mirrored vs. the convention
                    // used everywhere else (transaction list rows +
                    // transaction form's type toggle both use
                    // arrow_downward for income / arrow_upward for
                    // expense) — aligned to match.
                    icon: Icons.arrow_downward,
                    dark: false,
                    onTap: () => _openScreen(
                      context,
                      const TransactionFormScreen(
                        initialType: db.TransactionType.income,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _StaggeredItem(
                  animation: CurvedAnimation(
                    parent: _controller,
                    curve: _intervalFor(0),
                  ),
                  child: _SpeedDialOption(
                    key: const ValueKey('fab_option_expense'),
                    label: 'Catat Pengeluaran',
                    // M19: was `arrow_downward` — see note above.
                    icon: Icons.arrow_upward,
                    dark: false,
                    onTap: () => _openScreen(
                      context,
                      const TransactionFormScreen(
                        initialType: db.TransactionType.expense,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Rotated FAB-to-X: same slot the real FAB occupies, closes
                // the overlay (with the collapse animation) on tap.
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 0.785398, // 0 -> 45 degrees
                      child: child,
                    );
                  },
                  child: FloatingActionButton(
                    key: const ValueKey('home_fab_speed_dial_close'),
                    heroTag: 'fab_speed_dial_close',
                    onPressed: _close,
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

/// Fade (0->1) + scale (0.8->1.0) wrapper driven by a per-item [Interval]
/// of the shared stagger controller.
class _StaggeredItem extends StatelessWidget {
  const _StaggeredItem({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.8 + (0.2 * t),
            alignment: Alignment.centerRight,
            child: child,
          ),
        );
      },
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
