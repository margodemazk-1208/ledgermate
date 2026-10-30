import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../navigation/app_shell.dart';

/// Shared bottom navigation bar matching `docs/design/mockups/style.css`
/// `.bottom-nav`/`.nav-item` — Playfair Display script labels, a short
/// burgundy underline above the active icon instead of a filled background.
///
/// M18 (v1.3 perf, item 5): tab switches now mutate [currentTabIndexProvider]
/// instead of pushing/replacing routes — see `app_shell.dart`'s header for
/// why (state preservation + correct Android back-button behavior).
class AppBottomNav extends ConsumerWidget {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  onTap: () {
                    if (i == currentIndex) return;
                    ref.read(currentTabIndexProvider.notifier).setIndex(i);
                  },
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
