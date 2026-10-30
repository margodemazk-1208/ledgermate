import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
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
///
/// M21/Bug 1: this is now the SINGLE persistent instance living in
/// `AppShell`'s `Scaffold.bottomNavigationBar` slot (previously each of the
/// 6 tab screens embedded its own copy with an explicit `currentIndex`
/// constructor argument, which is what let the whole chrome get swept up
/// in each tab's `SlideTransition`). Reading [currentTabIndexProvider]
/// directly means this single widget instance never needs to be rebuilt
/// with a different constructor argument on tab switch — its position in
/// the tree, and therefore on screen, never changes.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  static List<_NavItemData> _items(AppLocalizations l10n) => [
    _NavItemData(Icons.home_outlined, Icons.home, l10n.appBottomNavHomeLabel),
    _NavItemData(
      Icons.receipt_long_outlined,
      Icons.receipt_long,
      l10n.appBottomNavTransactionsLabel,
    ),
    _NavItemData(
      Icons.track_changes_outlined,
      Icons.track_changes,
      l10n.appBottomNavGoalsLabel,
    ),
    _NavItemData(
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
      l10n.appBottomNavAssetsLabel,
    ),
    _NavItemData(
      Icons.bar_chart_outlined,
      Icons.bar_chart,
      l10n.appBottomNavAnalyticsLabel,
    ),
    _NavItemData(
      Icons.settings_outlined,
      Icons.settings,
      l10n.appBottomNavSettingsLabel,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final items = _items(l10n);
    final currentIndex = ref.watch(currentTabIndexProvider);
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
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    key: ValueKey('bottom_nav_item_$i'),
                    data: items[i],
                    active: i == currentIndex,
                    activeColor: AppColors.burgundySoft,
                    inactiveColor: unselected,
                    onTap: () {
                      if (i == currentIndex) return;
                      ref.read(currentTabIndexProvider.notifier).setIndex(i);
                    },
                  ),
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
            // M19/D18: at 360dp width, 6 equal-width nav slots leave less
            // room than some Indonesian labels (e.g. "Pengaturan") need at
            // their natural size — FittedBox scales the label down instead
            // of letting the Row overflow.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                data.label,
                style: AppTypography.script(fontSize: 10, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
