// Quick "Update Value" dialog for existing assets (FR-10, Step 3).
// The primary recurring interaction for users to periodically adjust current values
// without re-entering name, type, or purchase value.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/asset.dart';
import '../../../../core/presentation/widgets/press_scale.dart';
import '../../../../core/presentation/widgets/success_toast.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../application/assets_providers.dart';

class UpdateValueDialog extends ConsumerStatefulWidget {
  const UpdateValueDialog({super.key, required this.asset});

  final Asset asset;

  @override
  ConsumerState<UpdateValueDialog> createState() => _UpdateValueDialogState();
}

class _UpdateValueDialogState extends ConsumerState<UpdateValueDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _valueController;
  bool _isSubmitting = false;
  String? _errorMsg;
  int? _parsedValue;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(
      text: widget.asset.currentValue > 0
          ? formatRupiah(widget.asset.currentValue)
          : 'Rp 0',
    );
    _parsedValue = widget.asset.currentValue;
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _onValueChanged(String text) {
    setState(() {
      _errorMsg = null;
      _parsedValue = parseRupiah(text);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final newValue = _parsedValue;
    if (newValue == null || newValue < 0) {
      setState(() => _errorMsg = 'Nilai aset tidak boleh kosong atau negatif.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(assetsRepositoryProvider)
          .updateAssetCurrentValue(id: widget.asset.id, currentValue: newValue);
      if (mounted) {
        showSuccessToast(context, 'Nilai aset berhasil diperbarui');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Gagal memperbarui nilai: $e';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final purchase = widget.asset.purchaseValue;
    final oldCurrent = widget.asset.currentValue;
    final currentVal = _parsedValue ?? oldCurrent;
    final newGainLoss = currentVal - purchase;
    final newReturnPercent = purchase > 0
        ? (newGainLoss / purchase) * 100
        : 0.0;
    final isGain = newGainLoss >= 0;
    final deltaFromOld = currentVal - oldCurrent;

    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    final formattedDate = dateFormat.format(widget.asset.lastUpdatedAt);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.sync_alt, color: AppColors.brandTeal, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Update Nilai Aset',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Asset info header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.asset.assetName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tipe: ${widget.asset.assetType}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Modal Awal', style: theme.textTheme.bodySmall),
                        Text(
                          formatRupiah(purchase),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nilai Sebelumnya',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          formatRupiah(oldCurrent),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Terakhir diperbarui: $formattedDate',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Nilai Sekarang Baru',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const ValueKey('update_asset_value_input'),
                controller: _valueController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  border: OutlineInputBorder(),
                ),
                onChanged: _onValueChanged,
                validator: (val) => validateRupiahAmount(
                  val,
                  allowZero: true,
                  emptyMessage: 'Nilai aset tidak boleh kosong.',
                  invalidMessage: 'Nilai tidak boleh negatif.',
                ),
              ),
              const SizedBox(height: 12),

              // Live Gain/Loss preview
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      (isGain ? AppColors.savingsGreen : AppColors.expenseRed)
                          .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        (isGain ? AppColors.savingsGreen : AppColors.expenseRed)
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimasi Gain / Loss Baru:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${isGain ? '+' : ''}${formatRupiah(newGainLoss)} (${isGain ? '+' : ''}${newReturnPercent.toStringAsFixed(1)}%)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isGain
                                ? AppColors.savingsGreen
                                : AppColors.expenseRed,
                          ),
                        ),
                      ],
                    ),
                    if (deltaFromOld != 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Perubahan dari sebelumnya: ${deltaFromOld > 0 ? '+' : ''}${formatRupiah(deltaFromOld)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: deltaFromOld > 0
                              ? AppColors.savingsGreen
                              : AppColors.expenseRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (_errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMsg!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.expenseRed,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        PressScale(
          enabled: !_isSubmitting,
          child: FilledButton(
            key: const ValueKey('save_update_value_button'),
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandTeal,
              foregroundColor: Colors.white,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan Pembaruan'),
          ),
        ),
      ],
    );
  }
}
