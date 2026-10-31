import 'package:costbook/core/lang/app_lang.dart';

class ValidatorUtil {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

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
}
