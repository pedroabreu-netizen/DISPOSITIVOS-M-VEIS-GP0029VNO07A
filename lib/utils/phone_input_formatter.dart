import 'package:flutter/services.dart';

enum PhoneNumberFormat { brazil, northAmerica, groupsOfThree, international }

class PhoneCountry {
  const PhoneCountry({
    required this.name,
    required this.symbol,
    required this.dialCode,
    required this.maxDigits,
    required this.hint,
    required this.format,
  });

  final String name;
  final String symbol;
  final String dialCode;
  final int maxDigits;
  final String hint;
  final PhoneNumberFormat format;
}

const phoneCountries = [
  PhoneCountry(
    name: 'Brasil',
    symbol: '🇧🇷',
    dialCode: '+55',
    maxDigits: 11,
    hint: '(00) 00000-0000',
    format: PhoneNumberFormat.brazil,
  ),
  PhoneCountry(
    name: 'Estados Unidos',
    symbol: '🇺🇸',
    dialCode: '+1',
    maxDigits: 10,
    hint: '(000) 000-0000',
    format: PhoneNumberFormat.northAmerica,
  ),
  PhoneCountry(
    name: 'Portugal',
    symbol: '🇵🇹',
    dialCode: '+351',
    maxDigits: 9,
    hint: '000 000 000',
    format: PhoneNumberFormat.groupsOfThree,
  ),
  PhoneCountry(
    name: 'Outro',
    symbol: 'INT',
    dialCode: '+',
    maxDigits: 15,
    hint: 'Digite o número internacional',
    format: PhoneNumberFormat.international,
  ),
];

class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter(this.country);

  final PhoneCountry country;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > country.maxDigits
        ? digits.substring(0, country.maxDigits)
        : digits;
    final formatted = _format(limitedDigits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String digits) {
    return switch (country.format) {
      PhoneNumberFormat.brazil => _formatBrazil(digits),
      PhoneNumberFormat.northAmerica => _formatNorthAmerica(digits),
      PhoneNumberFormat.groupsOfThree => _formatGroups(digits, const [3, 3, 3]),
      PhoneNumberFormat.international => _formatGroups(digits, const [
        3,
        3,
        3,
        3,
        3,
      ]),
    };
  }

  String _formatBrazil(String digits) {
    if (digits.isEmpty) {
      return '';
    }

    if (digits.length <= 2) {
      return '($digits';
    }

    final ddd = digits.substring(0, 2);
    final number = digits.substring(2);

    if (number.length <= 4) {
      return '($ddd) $number';
    }

    if (number.length <= 8) {
      return '($ddd) ${number.substring(0, 4)}-${number.substring(4)}';
    }

    return '($ddd) ${number.substring(0, 5)}-${number.substring(5)}';
  }

  String _formatNorthAmerica(String digits) {
    if (digits.isEmpty) {
      return '';
    }

    if (digits.length <= 3) {
      return '($digits';
    }

    if (digits.length <= 6) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    }

    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  String _formatGroups(String digits, List<int> groups) {
    if (digits.isEmpty) {
      return '';
    }

    final parts = <String>[];
    var start = 0;

    for (final groupLength in groups) {
      if (start >= digits.length) {
        break;
      }

      final end = (start + groupLength).clamp(0, digits.length);
      parts.add(digits.substring(start, end));
      start = end;
    }

    return parts.join(' ');
  }
}
