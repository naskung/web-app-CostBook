import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/constants/install_guide.dart';
import 'package:costbook/core/helpers/web_app_browser_stub.dart'
    if (dart.library.js_interop) 'package:costbook/core/helpers/web_app_browser_web.dart'
    as browser;
import 'package:costbook/core/utils/install_util.dart';

// แอปบนเครื่องนี้: เพิ่มไว้ที่หน้าจอ (ติดตั้งแบบแอป) + ไอคอน / favicon เป็นโลโก้ร้าน
class WebAppHelper {
  static const String _dismissedKey = 'install_suggestion_dismissed';

  static bool get isInstalled => browser.isInstalled();

  static bool get canPrompt => browser.canPrompt();

  static InstallGuide get guide => InstallUtil.guideFor(defaultTargetPlatform, browser.browserName());

  // แนะนำให้เพิ่มไว้ที่หน้าจอได้ไหม: ยังไม่ได้เปิดแบบแอป + เปิดจาก home server (ตอนพัฒนา / ลิงก์ให้เพื่อน ไม่แนะนำ)
  static bool get canSuggest => !isInstalled && InstallUtil.isSameOrigin(ApiConstants.baseUrl);

  // เปิดหน้าต่างติดตั้งของ browser → true = ผู้ใช้กดติดตั้ง
  static Future<bool> prompt() => browser.prompt();

  static Future<bool> isDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dismissedKey) ?? false;
  }

  static Future<void> dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissedKey, true);
  }

  // version เปลี่ยนทุกครั้งที่เปลี่ยน / ลบโลโก้ (ShopLogo.refresh) → browser โหลดไอคอนใหม่
  static void showShopIcons(int version) {
    browser.setIcons(ApiConstants.companyIconUrl(64, version), ApiConstants.companyIconUrl(180, version));
  }
}
