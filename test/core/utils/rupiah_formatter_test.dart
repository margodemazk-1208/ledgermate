// M19/D18 regression test: `RupiahInputFormatter` previously crashed on
// 20+ digit input (int.parse throws FormatException once the digit string
// exceeds 64-bit int range, ~19 digits) — see docs/DECISIONS.md D18 and
// the M19 task body. A max-length guard now caps/truncates instead of
// crashing.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/utils/rupiah_formatter.dart';

TextEditingValue _value(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

void main() {
  group('RupiahInputFormatter', () {
    final formatter = RupiahInputFormatter();

    test('formats a normal amount with thousands separators', () {
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        _value('1500000'),
      );
      expect(result.text, '1.500.000');
    });

    test('does not crash on 20-digit input (regression, D18 audit)', () {
      // 20 digits — previously threw FormatException from int.parse
      // inside formatEditUpdate, crashing any form using this formatter.
      expect(
        () => formatter.formatEditUpdate(
          const TextEditingValue(text: ''),
          _value('12345678901234567890'),
        ),
        returnsNormally,
      );
    });

    test('does not crash on a pasted 30-digit garbage string', () {
      expect(
        () => formatter.formatEditUpdate(
          const TextEditingValue(text: ''),
          _value('1' * 30),
        ),
        returnsNormally,
      );
    });

    test(
      'truncates input beyond maxDigits instead of silently accepting it',
      () {
        final result = formatter.formatEditUpdate(
          const TextEditingValue(text: ''),
          _value('123456789012345678'), // 18 digits
        );
        final digitsOnly = result.text.replaceAll('.', '');
        expect(digitsOnly.length, RupiahInputFormatter.maxDigits);
        expect(digitsOnly, '123456789012345'); // first 15 digits kept
      },
    );

    test('empty input clears the field', () {
      final result = formatter.formatEditUpdate(
        _value('1.000'),
        const TextEditingValue(text: ''),
      );
      expect(result.text, '');
    });
  });
}
