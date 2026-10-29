// Add and edit form for Asset entity (FR-10, DECISIONS.md D8).
// Manual entry only — no price-fetching API.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/asset.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../application/assets_providers.dart';

class AssetFormScreen extends ConsumerStatefulWidget {
  const AssetFormScreen({super.key, this.asset});

  final Asset? asset;

  @override
  ConsumerState<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends ConsumerState<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _purchaseValueController;
  late final TextEditingController _currentValueController;

  bool _isSubmitting = false;
  String? _formError;

  static const _commonTypes = [
    'Emas',
    'Saham',
    'Reksadana',
    'Kripto',
    'Properti',
    'Deposito',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.asset;
    _nameController = TextEditingController(text: a?.assetName ?? '');
    _typeController = TextEditingController(text: a?.assetType ?? '');
    _purchaseValueController = TextEditingController(
      text: a != null && a.purchaseValue > 0
          ? formatRupiah(a.purchaseValue)
          : '',
    );
    _currentValueController = TextEditingController(
      text: a != null && a.currentValue >= 0
          ? formatRupiah(a.currentValue)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _purchaseValueController.dispose();
    _currentValueController.dispose();
    super.dispose();
  }

  int? _getPurchaseValue() => parseRupiah(_purchaseValueController.text);
  int? _getCurrentValue() => parseRupiah(_currentValueController.text);

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final purchase = _getPurchaseValue();
    final current = _getCurrentValue();

    if (purchase == null || purchase <= 0) {
      setState(() => _formError = 'Modal awal harus lebih besar dari 0.');
      return;
    }
    if (current == null || current < 0) {
      setState(
        () => _formError = 'Nilai sekarang tidak boleh kosong atau negatif.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      await ref
          .read(assetsRepositoryProvider)
          .saveAsset(
            id: widget.asset?.id,
            name: _nameController.text.trim(),
            type: _typeController.text.trim(),
            purchaseValue: purchase,
            currentValue: current,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _formError = 'Gagal menyimpan aset: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.asset != null;
    final purchase = _getPurchaseValue();
    final current = _getCurrentValue();

    final hasBothValues = purchase != null && purchase > 0 && current != null;
    final gainLoss = hasBothValues ? current - purchase : 0;
    final returnPercent = hasBothValues && purchase > 0
        ? (gainLoss / purchase) * 100
        : 0.0;
    final isGain = gainLoss >= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Aset' : 'Tambah Aset',
          style: AppTypography.script(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              // Name
              Text(
                'Nama Aset',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const ValueKey('asset_name_input'),
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'misal: Emas Antam 10g, BBCA, Reksadana Pasar Uang',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama aset tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Type
              Text(
                'Tipe Aset',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const ValueKey('asset_type_input'),
                controller: _typeController,
                decoration: const InputDecoration(
                  hintText: 'misal: Emas, Saham, Reksadana, Kripto',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Tipe aset tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              // Suggestion chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _commonTypes.map((t) {
                  return ActionChip(
                    label: Text(t, style: theme.textTheme.labelSmall),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      setState(() {
                        _typeController.text = t;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Purchase value
              Text(
                'Modal Awal / Nilai Beli (Rp)',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const ValueKey('asset_purchase_value_input'),
                controller: _purchaseValueController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                validator: (val) => validateRupiahAmount(
                  val,
                  allowZero: false,
                  emptyMessage: 'Modal awal tidak boleh kosong.',
                  invalidMessage: 'Modal awal harus lebih besar dari 0.',
                ),
              ),
              const SizedBox(height: 18),

              // Current value
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nilai Sekarang (Rp)',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('copy_purchase_to_current_button'),
                    onPressed: () {
                      final p = _purchaseValueController.text;
                      if (p.isNotEmpty) {
                        setState(() {
                          _currentValueController.text = p;
                        });
                      }
                    },
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Sama dg modal'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextFormField(
                key: const ValueKey('asset_current_value_input'),
                controller: _currentValueController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                validator: (val) => validateRupiahAmount(
                  val,
                  allowZero: true,
                  emptyMessage: 'Nilai sekarang tidak boleh kosong.',
                  invalidMessage: 'Nilai sekarang tidak boleh negatif.',
                ),
              ),
              const SizedBox(height: 20),

              // Live dynamic gain/loss calculation preview
              if (hasBothValues) ...[
                Container(
                  key: const ValueKey('gain_loss_preview_card'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        (isGain ? AppColors.savingsGreen : AppColors.expenseRed)
                            .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          (isGain
                                  ? AppColors.savingsGreen
                                  : AppColors.expenseRed)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estimasi Gain / Loss:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${isGain ? '+' : ''}${formatRupiah(gainLoss)} (${isGain ? '+' : ''}${returnPercent.toStringAsFixed(1)}%)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isGain
                              ? AppColors.savingsGreen
                              : AppColors.expenseRed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Offline notice reminder (DECISIONS.md D8)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.offline_pin_outlined,
                      size: 18,
                      color: AppColors.brandTeal,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '100% Offline. Nilai aset diperbarui secara manual oleh Anda kapan saja (D8).',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_formError != null) ...[
                Text(
                  _formError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.expenseRed,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Submit Button
              FilledButton(
                key: const ValueKey('save_asset_button'),
                onPressed: _isSubmitting ? null : _handleSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah Aset',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
