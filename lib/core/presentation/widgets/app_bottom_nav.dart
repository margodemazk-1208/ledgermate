import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../features/analytics/presentation/analytics_screen.dart';
import '../../../features/assets/presentation/assets_screen.dart';
import '../../../features/budget_engine/presentation/budget_home_screen.dart';
import '../../../features/goals/presentation/goals_screen.dart';
import '../../../features/settings/presentation/settings_screen.dart';
import '../../../features/transactions/presentation/transactions_screen.dart';

/// Shared bottom navigation bar matching `docs/design/mockups/style.css`
/// `.bottom-nav`/`.nav-item` — Playfair Display script labels, a short
/// burgundy underline above the active icon instead of a filled background.
///
/// Centralizing navigation here (rather than duplicating a `BottomNavigationBar`
/// + switch-statement per screen) also fixes a pre-M13 inconsistency where
/// Home used push-stacking while other tabs used push-replace.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const _items = <_NavItemData>[
    _NavItemData(Icons.home_outlined, Icons.home, 'Home'),
    _NavItemData(Icons.receipt_long_outlined, Icons.receipt_long, 'Transaksi'),
    _NavItemData(Icons.track_changes_outlined, Icons.track_changes, 'Goals'),
    _NavItemData(
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
      'Aset',
    ),
    _NavItemData(Icons.bar_chart_outlined, Icons.bar_chart, 'Analitik'),
    _NavItemData(Icons.settings_outlined, Icons.settings, 'Pengaturan'),
  ];

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    final screen = switch (index) {
      0 => const BudgetHomeScreen(),
      1 => const TransactionsScreen(),
      2 => const GoalsScreen(),
      3 => const AssetsScreen(),
      4 => const AnalyticsScreen(),
      _ => const SettingsScreen(),
    };
    if (index == 0) {
      // Home is the app's root tab — clear the stack so Back doesn't pile up
      // through every tab previously visited.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => screen),
        (route) => false,
      );
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF161616) : theme.colorScheme.surface;
    final unselected = isDark
        ? AppColors.darkTextMuted2
        : AppColors.lightTextMuted2;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++)
                _NavItem(
                  key: ValueKey('bottom_nav_item_$i'),
                  data: _items[i],
                  active: i == currentIndex,
                  activeColor: AppColors.burgundySoft,
                  inactiveColor: unselected,
                  onTap: () => _navigate(context, i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.data,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final _NavItemData data;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 3,
              width: 16,
              child: active
                  ? DecoratedBox(decoration: BoxDecoration(color: activeColor))
                  : null,
            ),
            const SizedBox(height: 4),
            Icon(active ? data.activeIcon : data.icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              data.label,
              style: AppTypography.script(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
