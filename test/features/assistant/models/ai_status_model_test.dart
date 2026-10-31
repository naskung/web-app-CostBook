import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/assistant/models/ai_status_model.dart';

void main() {
  group('AiStatusModel', () {
    test('fromJson อ่านค่าได้ถูกต้อง', () {
      final status = AiStatusModel.fromJson({
        'enabled': true,
        'provider': 'claude',
        'model': 'claude-opus-5-5',
        'source': 'settings',
        'web_search': true,
        'has_own_key': true,
        'key_hint': '…a1B2',
        'free_available': true,
      });
      expect(
        status,
        const AiStatusModel(
          enabled: true,
          provider: AiStatusModel.claude,
          model: 'claude-opus-5-5',
          source: 'settings',
          webSearch: true,
          hasOwnKey: true,
          keyHint: '…a1B2',
          freeAvailable: true,
        ),
      );
    });

    test('ไม่มีข้อมูล = ไม่มี AI', () {
      final status = AiStatusModel.fromJson({});
      expect([status.enabled, status.provider, status.webSearch], [false, AiStatusModel.none, false]);
    });

    test('isFree เป็น true เมื่อใช้ Gemini ฟรี', () {
      expect(const AiStatusModel(provider: AiStatusModel.gemini).isFree, true);
      expect(const AiStatusModel(provider: AiStatusModel.claude).isFree, false);
    });
  });
}
