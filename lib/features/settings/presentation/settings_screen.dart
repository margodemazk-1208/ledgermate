import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/category.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/presentation/navigation/slide_page_route.dart';
import '../../../core/presentation/widgets/app_bottom_nav.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../export_import/presentation/widgets/data_management_card.dart';
import '../../notifications/data/notification_service.dart';
import '../../wallets/presentation/wallets_screen.dart';
import '../application/settings_providers.dart';

/// Main Settings screen hosting Data Management (FR-08), Preferences (FR-09),
/// Category Management (FR-09), and Local Notifications (FR-11).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _formatTime(int minutes) {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final min = (minutes % 60).toString().padLeft(2, '0');
    return '$hour:$min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDarkMode =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final profileAsync = ref.watch(settingsProfileStreamProvider);
    final profile = profileAsync.value;
    final currentLanguage = profile?.language ?? AppLanguage.id;
    final packageInfoAsync = ref.watch(appPackageInfoProvider);

    // D18/M17 bug #2: safety net for installs that completed onboarding
    // BEFORE this fix shipped (so the onboarding-completion hook never ran
    // for them) — the first time this screen is shown with a loaded
    // profile that hasn't been bootstrapped yet, schedule the
    // default-enabled notifications and request the permission. No-ops
    // once `notificationsBootstrapped` is persisted as true (the condition
    // below stops re-scheduling once that flips).
    if (profile != null && !profile.notificationsBootstrapped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(settingsRepositoryProvider)
            .bootstrapDefaultNotificationsIfNeeded();
      });
    }

    return Scaffold(
      key: const ValueKey('settings_screen'),
      appBar: AppBar(
        title: Text('Pengaturan', style: AppTypography.script(fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // 1. Data Backup & Restore (FR-08)
          const DataManagementCard(),
          const SizedBox(height: 20),

          // 2. Preferences Card (Theme & Language - FR-09)
          Card(
            key: const ValueKey('settings_preferences_card'),
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // M19/D18: burgundy pulled off every section-header icon badge —
                          // repeating it 5x on one screen was the clearest
                          // case of the "accent used too heavily" audit
                          // finding (docs/DESIGN.md ~10-15% guidance).
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.06,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: theme.textTheme.bodyLarge?.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tampilan & Bahasa',
                              style: AppTypography.script(fontSize: 17),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kustomisasi tema dan bahasa antarmuka',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    key: const ValueKey('settings_dark_mode_switch'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mode Gelap (Dark Mode)'),
                    subtitle: Text(
                      isDarkMode
                          ? 'Tema gelap aktif (rekomendasi OLED)'
                          : 'Tema terang aktif',
                      style: theme.textTheme.bodySmall,
                    ),
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    value: isDarkMode,
                    onChanged: (val) {
                      final newMode = val ? ThemeMode.dark : ThemeMode.light;
                      ref.read(themeModeProvider.notifier).set(newMode);
                      ref
                          .read(settingsRepositoryProvider)
                          .updateTheme(
                            val ? AppThemeSetting.dark : AppThemeSetting.light,
                          );
                    },
                  ),
                  const Divider(height: 20),
                  ListTile(
                    key: const ValueKey('settings_language_tile'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.language,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    title: const Text('Bahasa Aplikasi'),
                    subtitle: Text(
                      currentLanguage == AppLanguage.id
                          ? 'Bahasa Indonesia (Aktif)'
                          : 'English (Active)',
                    ),
                    trailing: DropdownButton<AppLanguage>(
                      value: currentLanguage,
                      underline: const SizedBox.shrink(),
                      onChanged: (lang) {
                        if (lang != null) {
                          ref
                              .read(settingsRepositoryProvider)
                              .updateLanguage(lang);
                          ref
                              .read(appLocaleProvider.notifier)
                              .setFromLanguage(lang);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: AppLanguage.id,
                          child: Text('Bahasa Indonesia'),
                        ),
                        DropdownMenuItem(
                          value: AppLanguage.en,
                          child: Text('English'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Local Notifications Card (FR-11)
          Card(
            key: const ValueKey('settings_notifications_card'),
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // M19/D18: burgundy pulled off every section-header icon badge —
                          // repeating it 5x on one screen was the clearest
                          // case of the "accent used too heavily" audit
                          // finding (docs/DESIGN.md ~10-15% guidance).
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.06,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: theme.textTheme.bodyLarge?.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifikasi & Pengingat',
                              style: AppTypography.script(fontSize: 17),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '100% Offline via Alarm Manager lokal',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Daily reminder switch + time picker
                  SwitchListTile(
                    key: const ValueKey('settings_daily_reminder_switch'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pengingat Catat Harian'),
                    subtitle: Text(
                      'Setiap hari pukul ${_formatTime(profile?.notifDailyReminderTime ?? 1260)} WIB (ketuk jam untuk mengubah)',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: profile?.notifDailyReminderEnabled ?? true,
                    onChanged: (val) async {
                      if (val) {
                        await ref
                            .read(notificationServiceProvider)
                            .requestPermission();
                      }
                      await ref
                          .read(settingsRepositoryProvider)
                          .updateDailyReminder(
                            enabled: val,
                            timeMinutes:
                                profile?.notifDailyReminderTime ?? 1260,
                          );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 36, bottom: 8),
                    child: OutlinedButton.icon(
                      key: const ValueKey('settings_reminder_time_picker'),
                      onPressed: (profile?.notifDailyReminderEnabled ?? true)
                          ? () async {
                              final curMin =
                                  profile?.notifDailyReminderTime ?? 1260;
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: curMin ~/ 60,
                                  minute: curMin % 60,
                                ),
                              );
                              if (picked != null) {
                                final minutes =
                                    picked.hour * 60 + picked.minute;
                                await ref
                                    .read(settingsRepositoryProvider)
                                    .updateDailyReminder(
                                      enabled: true,
                                      timeMinutes: minutes,
                                    );
                              }
                            }
                          : null,
                      icon: const Icon(Icons.schedule, size: 18),
                      label: Text(
                        'Ubah Jam (${_formatTime(profile?.notifDailyReminderTime ?? 1260)})',
                      ),
                    ),
                  ),
                  const Divider(height: 20),
                  // Limit alert switch
                  SwitchListTile(
                    key: const ValueKey('settings_limit_alert_switch'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Peringatan Limit Anggaran'),
                    subtitle: Text(
                      'Pemberitahuan real-time saat uang jajan aman hari ini mendekati 0 atau minus.',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: profile?.notifLimitAlertEnabled ?? true,
                    onChanged: (val) async {
                      await ref
                          .read(settingsRepositoryProvider)
                          .updateLimitAlert(enabled: val);
                    },
                  ),
                  const Divider(height: 20),
                  // Pay cycle alert switch
                  SwitchListTile(
                    key: const ValueKey('settings_pay_cycle_switch'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Siklus Gajian Baru'),
                    subtitle: Text(
                      'Pemberitahuan saat memasuki tanggal gajian atau siklus baru.',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: profile?.notifPayCycleEnabled ?? true,
                    onChanged: (val) async {
                      await ref
                          .read(settingsRepositoryProvider)
                          .updatePayCycleAlert(enabled: val);
                    },
                  ),
                  const Divider(height: 20),
                  // Goal milestone alert switch
                  SwitchListTile(
                    key: const ValueKey('settings_goal_milestone_switch'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Milestone Target Tabungan'),
                    subtitle: Text(
                      'Pemberitahuan saat progres goal mencapai 25%, 50%, 75%, dan 100%.',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: profile?.notifGoalMilestoneEnabled ?? true,
                    onChanged: (val) async {
                      await ref
                          .read(settingsRepositoryProvider)
                          .updateGoalMilestoneAlert(enabled: val);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4. Wallets Management Card (FR-12, D16)
          const _WalletsManagementCard(),
          const SizedBox(height: 20),

          // 5. Category Management Card (FR-09)
          const _CategoryManagementCard(),
          const SizedBox(height: 20),

          // 5. About & Architecture Info Card
          Card(
            key: const ValueKey('settings_about_card'),
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // M19/D18: burgundy pulled off every section-header icon badge —
                          // repeating it 5x on one screen was the clearest
                          // case of the "accent used too heavily" audit
                          // finding (docs/DESIGN.md ~10-15% guidance).
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.06,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: theme.textTheme.bodyLarge?.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tentang LedgerMate',
                              style: AppTypography.script(fontSize: 17),
                            ),
                            const SizedBox(height: 2),
                            // M19/D18: reads the REAL installed build's
                            // version dynamically (package_info_plus)
                            // instead of a hand-typed literal that
                            // immediately drifted from the real version.
                            packageInfoAsync.when(
                              data: (info) => Text(
                                'Versi ${info.version}+${info.buildNumber} '
                                '(100% Offline, Tanpa Server)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                              loading: () => Text(
                                'Memuat versi...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                              error: (_, _) => Text(
                                '100% Offline, Tanpa Server',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'LedgerMate adalah pelacak anggaran harian pintar berbasis offline-first. Seluruh data keuangan Anda tersimpan secara lokal di perangkat Anda menggunakan Isar Database.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.8,
                      ),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 5),
    );
  }
}

/// Card displaying and managing transaction categories (FR-09).
class _CategoryManagementCard extends ConsumerWidget {
  const _CategoryManagementCard();

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    var isSubmitting = false;
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Tambah Kategori Baru'),
          content: TextField(
            key: const ValueKey('add_category_name_field'),
            controller: controller,
            autofocus: true,
            enabled: !isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Nama Kategori',
              hintText: 'Contoh: Investasi, Zakat, Liburan',
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            FilledButton(
              key: const ValueKey('add_category_confirm_button'),
              // D18/M17 bug #8: category dialogs previously had no
              // isSubmitting guard at all — a double-tap could fire
              // `addCategory` twice concurrently.
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;
                      setDialogState(() => isSubmitting = true);
                      try {
                        await ref
                            .read(settingsRepositoryProvider)
                            .addCategory(name);
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll('ArgumentError: ', ''),
                              ),
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    final controller = TextEditingController(text: category.name);
    var isSubmitting = false;
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Ubah Nama Kategori'),
          content: TextField(
            key: const ValueKey('edit_category_name_field'),
            controller: controller,
            autofocus: true,
            enabled: !isSubmitting,
            decoration: const InputDecoration(labelText: 'Nama Kategori'),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            FilledButton(
              key: const ValueKey('edit_category_confirm_button'),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;
                      setDialogState(() => isSubmitting = true);
                      try {
                        await ref
                            .read(settingsRepositoryProvider)
                            .updateCategory(category.id, name);
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll('ArgumentError: ', ''),
                              ),
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    var isSubmitting = false;
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Hapus Kategori?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kategori "${category.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            FilledButton(
              key: const ValueKey('delete_category_confirm_button'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);
                      try {
                        await ref
                            .read(settingsRepositoryProvider)
                            .deleteCategory(category.id);
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      } catch (e) {
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll('StateError: ', ''),
                              ),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .error,
                            ),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Hapus'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(settingsCategoriesStreamProvider);

    return Card(
      key: const ValueKey('settings_category_card'),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // M19/D18: burgundy pulled off every section-header icon badge —
                    // repeating it 5x on one screen was the clearest
                    // case of the "accent used too heavily" audit
                    // finding (docs/DESIGN.md ~10-15% guidance).
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.category,
                    color: theme.textTheme.bodyLarge?.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelola Kategori',
                        style: AppTypography.script(fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kategori bawaan & kustom untuk transaksi',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  key: const ValueKey('settings_add_category_button'),
                  onPressed: () => _showAddCategoryDialog(context, ref),
                  icon: const Icon(Icons.add),
                  tooltip: 'Tambah Kategori',
                ),
              ],
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Memuat kategori default...'),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(cat.name),
                      trailing: cat.isDefault
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Bawaan',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  tooltip: 'Ubah Nama',
                                  onPressed: () => _showEditCategoryDialog(
                                    context,
                                    ref,
                                    cat,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: theme.colorScheme.error,
                                  ),
                                  tooltip: 'Hapus Kategori',
                                  onPressed: () => _showDeleteCategoryDialog(
                                    context,
                                    ref,
                                    cat,
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text('Gagal memuat kategori: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletsManagementCard extends StatelessWidget {
  const _WalletsManagementCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey('settings_wallets_card'),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // M19/D18: burgundy pulled off every section-header icon badge —
                    // repeating it 5x on one screen was the clearest
                    // case of the "accent used too heavily" audit
                    // finding (docs/DESIGN.md ~10-15% guidance).
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: theme.textTheme.bodyLarge?.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kelola Dompet & Rekening',
                        style: AppTypography.script(fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Atur dompet, rekening bank, saldo awal & transfer',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  key: const ValueKey('settings_open_wallets_button'),
                  onPressed: () {
                    Navigator.of(context).push(
                      SlidePageRoute(builder: (_) => const WalletsScreen()),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Buka Kelola Dompet',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
