import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/wallet.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../application/wallet_providers.dart';
import '../utils/wallet_icons.dart';

/// Add / Edit Wallet Screen (FR-12, D16).
class WalletFormScreen extends ConsumerStatefulWidget {
  const WalletFormScreen({super.key, this.wallet});

  final Wallet? wallet;

  @override
  ConsumerState<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends ConsumerState<WalletFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late String _selectedIcon;
  late bool _includeInDailyBudget;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final w = widget.wallet;
    _nameController = TextEditingController(text: w?.name ?? '');
    _balanceController = TextEditingController(
      text: w != null && w.startingBalance > 0
          ? formatRupiah(w.startingBalance).replaceAll('Rp ', '')
          : (w != null ? '0' : ''),
    );
    _selectedIcon = w?.icon ?? 'account_balance_wallet';
    _includeInDailyBudget = w?.includeInDailyBudget ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final startingBalance = parseRupiah(_balanceController.text) ?? 0;
    try {
      await ref
          .read(walletRepositoryProvider)
          .saveWallet(
            id: widget.wallet?.id,
            name: _nameController.text.trim(),
            icon: _selectedIcon,
            startingBalance: startingBalance,
            includeInDailyBudget: _includeInDailyBudget,
          );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.wallet != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Dompet' : 'Tambah Dompet',
          style: AppTypography.script(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error banner
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.expenseRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.expenseRed.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.expenseRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.expenseRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Name Field
              TextFormField(
                key: const ValueKey('wallet_name_field'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Dompet',
                  hintText: 'Misal: BCA, Tunai, Gopay, Bibit',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama dompet tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. Icon Picker
              Text(
                'Pilih Ikon',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                key: const ValueKey('wallet_icon_picker'),
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: supportedWalletIcons.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final item = supportedWalletIcons[i];
                    final isSelected = item.key == _selectedIcon;
                    return InkWell(
                      key: ValueKey('wallet_icon_${item.key}'),
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedIcon = item.key;
                        });
                      },
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.brandTeal.withValues(alpha: 0.15)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandTeal
                                : theme.dividerColor.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? AppColors.brandTeal
                                  : theme.iconTheme.color,
                              size: 24,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label.split(' / ').first,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                color: isSelected
                                    ? AppColors.brandTeal
                                    : theme.textTheme.bodySmall?.color,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 3. Starting Balance
              TextFormField(
                key: const ValueKey('wallet_starting_balance_field'),
                controller: _balanceController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Saldo Awal',
                  prefixText: 'Rp ',
                  helperText: 'Saldo saat dompet pertama kali dibuat/dihitung (whole Rupiah).',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  final parsed = parseRupiah(val ?? '') ?? 0;
                  if (parsed < 0) {
                    return 'Saldo awal tidak boleh negatif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 4. includeInDailyBudget toggle
              Card(
                elevation: 0,
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: SwitchListTile(
                  key: const ValueKey('wallet_include_budget_switch'),
                  value: _includeInDailyBudget,
                  activeThumbColor: AppColors.brandTeal,
                  title: const Text('Hitung dalam Budget Harian'),
                  subtitle: const Text(
                    'Jika aktif, transaksi di dompet ini akan memengaruhi sisa uang jajan harianmu (BR-04). Matikan untuk dompet tabungan/investasi.',
                  ),
                  onChanged: (val) {
                    setState(() {
                      _includeInDailyBudget = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // 5. Submit Button
              FilledButton.icon(
                key: const ValueKey('wallet_save_button'),
                onPressed: _isSubmitting ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(isEdit ? 'Simpan Perubahan' : 'Buat Dompet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
