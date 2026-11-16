import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/features/assistant/models/ai_preset_model.dart';
import 'package:costbook/features/assistant/models/ai_settings_model.dart';
import 'package:costbook/features/assistant/models/ai_status_model.dart';

void main() {
  group('AiPresetModel', () {
    test('ที่อยู่ตรงกับเจ้าที่มีในรายการ ได้ id ของเจ้านั้น (มี / ท้ายก็ได้)', () {
      expect(AiPresetModel.idOfBaseUrl('https://api.deepseek.com/v1'), 'deepseek');
      expect(AiPresetModel.idOfBaseUrl(' https://api.groq.com/openai/v1/ '), 'groq');
    });

    test('ที่อยู่อื่น = กำหนดเอง', () {
      expect(AiPresetModel.idOfBaseUrl('https://my-ai.example.com/v1'), AiPresetModel.customId);
    });

    test('byId หาไม่เจอ = null', () {
      expect(AiPresetModel.byId('typhoon')?.baseUrl, 'https://api.opentyphoon.ai/v1');
      expect(AiPresetModel.byId(AiPresetModel.customId), isNull);
    });

    test('ทุกเจ้ามีที่อยู่ http(s) ไม่มี / ท้าย และ id ไม่ซ้ำ', () {
      final ids = AiPresetModel.all.map((preset) => preset.id).toSet();
      expect(ids.length, AiPresetModel.all.length);
      for (final preset in AiPresetModel.all) {
        expect(preset.baseUrl.startsWith('http'), isTrue, reason: preset.id);
        expect(preset.baseUrl.endsWith('/'), isFalse, reason: preset.id);
      }
    });
  });

  group('AiSettingsModel', () {
    test('toJson ตัดช่องว่างหน้า-หลังทุกช่อง', () {
      const settings = AiSettingsModel(
        provider: AiStatusModel.openai,
        apiKey: '  sk-1  ',
        baseUrl: ' https://api.openai.com/v1 ',
        model: ' gpt ',
      );
      expect(settings.toJson(), {
        'provider': 'openai',
        'api_key': 'sk-1',
        'base_url': 'https://api.openai.com/v1',
        'model': 'gpt',
      });
    });
  });
}
