import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/constants/install_guide.dart';
import 'package:costbook/core/utils/install_util.dart';

void main() {
  group('InstallUtil.guideFor', () {
    test('iPhone / iPad ทุก browser ใช้ปุ่มแชร์ → เพิ่มไปยังหน้าจอโฮม', () {
      expect(InstallUtil.guideFor(TargetPlatform.iOS, 'safari'), InstallGuide.iphone);
      expect(InstallUtil.guideFor(TargetPlatform.iOS, 'chrome'), InstallGuide.iphone);
    });

    test('Android ทุก browser ใช้เมนู → ติดตั้งแอป', () {
      expect(InstallUtil.guideFor(TargetPlatform.android, 'chrome'), InstallGuide.android);
      expect(InstallUtil.guideFor(TargetPlatform.android, 'firefox'), InstallGuide.android);
      expect(InstallUtil.guideFor(TargetPlatform.android, 'samsung'), InstallGuide.android);
    });

    test('Mac + Safari ใช้ เพิ่มไปยัง Dock / Mac + Chrome ใช้วิธีของคอม', () {
      expect(InstallUtil.guideFor(TargetPlatform.macOS, 'safari'), InstallGuide.macSafari);
      expect(InstallUtil.guideFor(TargetPlatform.macOS, 'chrome'), InstallGuide.desktop);
    });

    test('คอม Chrome / Edge ใช้วิธีของคอม / Firefox บนคอมแนะนำให้เปิดใน Chrome หรือ Edge', () {
      expect(InstallUtil.guideFor(TargetPlatform.windows, 'edge'), InstallGuide.desktop);
      expect(InstallUtil.guideFor(TargetPlatform.linux, 'chrome'), InstallGuide.desktop);
      expect(InstallUtil.guideFor(TargetPlatform.windows, 'firefox'), InstallGuide.firefoxDesktop);
      expect(InstallUtil.guideFor(TargetPlatform.macOS, 'firefox'), InstallGuide.firefoxDesktop);
    });
  });

  test('otherGuides ได้วิธีของเครื่องอื่นทั้งหมด ไม่ซ้ำกับเครื่องนี้', () {
    final others = InstallUtil.otherGuides(InstallGuide.iphone);
    expect(others.length, InstallGuide.values.length - 1);
    expect(others, isNot(contains(InstallGuide.iphone)));
  });

  test('isSameOrigin: home server (/api/v1) = ใช่ / ตอนพัฒนา หรือลิงก์ให้เพื่อน (http...) = ไม่ใช่', () {
    expect(InstallUtil.isSameOrigin('/api/v1'), isTrue);
    expect(InstallUtil.isSameOrigin('http://localhost:8080/api/v1'), isFalse);
    expect(InstallUtil.isSameOrigin('https://abc.trycloudflare.com/api/v1'), isFalse);
  });

  test('ทุกวิธีมีข้อความหัวข้อ + ขั้นตอนในไฟล์ภาษา', () {
    final th = jsonDecode(File('assets/lang/th.json').readAsStringSync()) as Map<String, dynamic>;
    for (final guide in InstallGuide.values) {
      expect(th.containsKey(guide.titleKey), isTrue, reason: guide.titleKey);
      expect(th.containsKey(guide.stepsKey), isTrue, reason: guide.stepsKey);
    }
  });
}
