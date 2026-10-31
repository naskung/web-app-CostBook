import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/core/utils/error_util.dart';

void main() {
  group('ErrorUtil.codeOf', () {
    test('ApiException ได้ code จาก API', () {
      expect(ErrorUtil.codeOf(ApiException('stock_not_enough')), 'stock_not_enough');
    });

    test('error อื่น ได้ unknown_error', () {
      expect(ErrorUtil.codeOf(Exception('boom')), 'unknown_error');
    });
  });
}
