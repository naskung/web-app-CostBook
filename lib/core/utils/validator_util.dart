import 'package:costbook/core/lang/app_lang.dart';

class ValidatorUtil {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _taxIdPattern = RegExp(r'^[0-9]{13}$');

  // ตรงกับ API: นับเป็นตัวอักษร (ภาษาไทย 1 ตัว = 1)
  static const int minPasswordLength = 6;

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'validation.required'.tr;
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (!_emailPattern.hasMatch(value?.trim() ?? '')) return 'validation.email_invalid'.tr;
    return null;
  }

  static String? taxId(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!_taxIdPattern.hasMatch(text)) return 'validation.tax_id_invalid'.tr;
    return null;
  }

  static String? positiveNumber(String? value) {
    final number = double.tryParse(value?.replaceAll(',', '').trim() ?? '');
    if (number == null || number <= 0) return 'validation.positive_number'.tr;
    return null;
  }

  static String? zeroOrMore(String? value) {
    final text = value?.replaceAll(',', '').trim() ?? '';
    if (text.isEmpty) return null;
    final number = double.tryParse(text);
    if (number == null || number < 0) return 'validation.zero_or_more'.tr;
    return null;
  }

  static String? positiveInteger(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number <= 0) return 'validation.positive_integer'.tr;
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'validation.required'.tr;
    if (text.runes.length < minPasswordLength) {
      return 'validation.password_too_short'.trParams({'min': '$minPasswordLength'});
    }
    return null;
  }

  static String? passwordMatch(String? value, String password) {
    if ((value ?? '') != password) return 'validation.password_mismatch'.tr;
    return null;
  }
}
