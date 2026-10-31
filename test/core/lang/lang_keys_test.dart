import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('th.json กับ en.json มี key ตรงกัน', () {
    final th = jsonDecode(File('assets/lang/th.json').readAsStringSync()) as Map<String, dynamic>;
    final en = jsonDecode(File('assets/lang/en.json').readAsStringSync()) as Map<String, dynamic>;
    expect(en.keys.toSet(), th.keys.toSet());
  });
}
