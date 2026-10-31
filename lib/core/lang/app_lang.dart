import 'dart:convert';

import 'package:flutter/services.dart';

class AppLang {
  static String currentCode = 'th';
  static Map<String, dynamic> _texts = {};

  static Future<void> load(String code) async {
    final jsonText = await rootBundle.loadString('assets/lang/$code.json');
    _texts = jsonDecode(jsonText) as Map<String, dynamic>;
    currentCode = code;
  }

  static String text(String key) {
    return _texts[key]?.toString() ?? key;
  }
}

extension TrExtension on String {
  String get tr => AppLang.text(this);

  String trParams(Map<String, String> params) {
    var result = tr;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
