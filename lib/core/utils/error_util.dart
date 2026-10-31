import 'package:costbook/core/network/api_exception.dart';

class ErrorUtil {
  static String codeOf(Object error) {
    if (error is ApiException) return error.code;
    return 'unknown_error';
  }
}
