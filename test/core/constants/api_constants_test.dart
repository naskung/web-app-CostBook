import 'dart:convert';
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

  test('URL ไอคอนแอป มีขนาด + ?v= ตามเวอร์ชันโลโก้ (เปลี่ยนโลโก้แล้ว URL เปลี่ยน)', () {
    expect(ApiConstants.companyIconUrl(64, 2), '${ApiConstants.baseUrl}/company/icon?size=64&v=2');
  });

  test('web/index.html: favicon เริ่มต้นเป็นไอคอน CostBook แล้วแอปเปลี่ยนเป็นโลโก้ร้านให้ (setIcons)', () {
    final indexHtml = File('web/index.html').readAsStringSync();
    expect(indexHtml, contains('<link id="favicon" rel="icon" type="image/png" href="favicon.png">'));
    expect(indexHtml, contains('setIcons: function'));
    expect(File('web/favicon.png').existsSync(), isTrue);
  });

  test('web/manifest.json: ไอคอน 192 / 512 มาจาก API (โลโก้ร้าน หรือไอคอนเริ่มต้น)', () {
    final manifest = jsonDecode(File('web/manifest.json').readAsStringSync()) as Map<String, dynamic>;
    final sources = [for (final icon in manifest['icons'] as List) (icon as Map<String, dynamic>)['src']];
    expect(sources, ['api/v1/company/icon?size=192', 'api/v1/company/icon?size=512']);
  });
}
