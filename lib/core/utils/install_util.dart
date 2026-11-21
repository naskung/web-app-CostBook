import 'package:flutter/foundation.dart';

import 'package:costbook/core/constants/install_guide.dart';

class InstallUtil {
  // browser = ชื่อย่อจาก costbookWebApp.browser() ใน web/index.html เช่น chrome / safari / firefox
  static InstallGuide guideFor(TargetPlatform platform, String browser) {
    if (platform == TargetPlatform.iOS) return InstallGuide.iphone;
    if (platform == TargetPlatform.android) return InstallGuide.android;
    if (browser == 'firefox') return InstallGuide.firefoxDesktop;
    if (platform == TargetPlatform.macOS && browser == 'safari') return InstallGuide.macSafari;
    return InstallGuide.desktop;
  }

  static List<InstallGuide> otherGuides(InstallGuide guide) {
    return InstallGuide.values.where((other) => other != guide).toList();
  }

  // หน้าเว็บกับ API อยู่ที่เดียวกัน (home server: API_URL=/api/v1) → ไอคอนใน manifest.json โหลดได้ ติดตั้งแล้วไอคอนไม่หาย
  static bool isSameOrigin(String apiBaseUrl) => apiBaseUrl.startsWith('/');
}
