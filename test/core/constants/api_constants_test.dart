import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/api_constants.dart';

void main() {
  test('URL โลโก้ร้าน คือ baseUrl + /company/logo', () {
    expect(ApiConstants.companyLogoUrl, '${ApiConstants.baseUrl}/company/logo');
  });

  test('URL รูปโปรไฟล์ มี ?v= ตามเวอร์ชันรูป (เปลี่ยนรูปแล้ว URL เปลี่ยน)', () {
    expect(ApiConstants.userAvatarUrl('u1', 5), '${ApiConstants.baseUrl}/users/u1/avatar?v=5');
  });

  test('favicon ใน web/index.html ใช้ URL โลโก้ร้านเดียวกับ ApiConstants', () {
    final indexHtml = File('web/index.html').readAsStringSync();
    expect(indexHtml, contains('<link rel="icon" href="${ApiConstants.companyLogoUrl}"/>'));
  });
}
