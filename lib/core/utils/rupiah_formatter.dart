// Shared Rupiah formatting/parsing + input validation, per FR-02's
// "format Rupiah otomatis, tidak boleh negatif/kosong" requirement. Lives
// in `core/utils/` per `docs/ARCHITECTURE.md` ("Rupiah formatting, date
// math, validators") so every amount field (onboarding, M3 transactions,
// goals, assets) shares one formatter instead of each screen inventing
// its own.
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final NumberFormat _groupingFormat = NumberFormat.decimalPattern('id_ID');

/// Formats a whole-Rupiah [int] amount for display, e.g. `1500000` ->
/// `"Rp 1.500.000"`.
String formatRupiah(int amount) => 'Rp ${_groupingFormat.format(amount)}';

/// Strips everything but digits and parses the remainder as a whole-Rupiah
/// [int]. Returns `null` for empty/non-numeric input instead of throwing,
/// so callers can treat it as "not entered yet".
int? parseRupiah(String input) {
  final digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) return null;
  return int.tryParse(digitsOnly);
}

/// Live-formats a Rupiah amount field as the user types (adds thousands
/// separators), keeping the cursor at the end — simple and predictable
/// for a field that's always "type digits, see it grouped".
class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final value = int.parse(digitsOnly);
    final formatted = _groupingFormat.format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Validates a Rupiah amount input per FR-02: not empty, not negative.
/// [allowZero] defaults to `false` because every current onboarding use
/// (initial income, mandatory expense amount) represents a real nonzero
/// figure; pass `true` for fields where zero is a legitimate value.
String? validateRupiahAmount(
  String? input, {
  bool allowZero = false,
  required String emptyMessage,
  required String invalidMessage,
}) {
  final parsed = parseRupiah(input ?? '');
  if (parsed == null) return emptyMessage;
  if (parsed < 0 || (parsed == 0 && !allowZero)) return invalidMessage;
  return null;
}
