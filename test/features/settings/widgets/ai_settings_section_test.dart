import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/features/assistant/bloc/assistant_bloc.dart';
import 'package:costbook/features/assistant/models/ai_settings_model.dart';
import 'package:costbook/features/assistant/models/ai_status_model.dart';
import 'package:costbook/features/settings/widgets/ai_settings_section.dart';

class MockAssistantBloc extends MockBloc<AssistantEvent, AssistantState> implements AssistantBloc {}

void main() {
  late MockAssistantBloc bloc;
  const free = AiStatusModel(enabled: true, provider: AiStatusModel.gemini, source: 'env', freeAvailable: true);
  const deepSeek = AiStatusModel(
    enabled: true,
    provider: AiStatusModel.openai,
    model: 'deepseek-chat',
    baseUrl: 'https://api.deepseek.com/v1',
    source: 'settings',
    hasOwnKey: true,
  );

  setUpAll(() async {
    await AppLang.load('th');
    registerFallbackValue(AssistantCleared());
  });

  setUp(() {
    bloc = MockAssistantBloc();
  });

  Future<void> pumpSection(WidgetTester tester, AssistantState state) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    when(() => bloc.state).thenReturn(state);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<AssistantBloc>.value(
            value: bloc,
            child: const SingleChildScrollView(child: AiSettingsSection()),
          ),
        ),
      ),
    );
  }

  // เปิดช่อง "ผู้ให้บริการ AI" แล้วเลือก (label = ชื่อที่เห็นในรายการ)
  Future<void> chooseProvider(WidgetTester tester, String current, String label) async {
    await tester.tap(find.text(current));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> chooseOpenAi(WidgetTester tester) =>
      chooseProvider(tester, 'settings.ai_provider_claude'.tr, 'OpenAI (ChatGPT)');

  AiSettingsModel savedSettings() {
    final event = verify(() => bloc.add(captureAny(that: isA<AssistantAiSaved>()))).captured.last as AssistantAiSaved;
    return event.settings;
  }

  testWidgets('ไม่มีแท็บแล้ว เหลือช่องเลือกผู้ให้บริการช่องเดียว', (tester) async {
    await pumpSection(tester, const AssistantState(ai: free));
    expect(find.byType(SegmentedButton<String>), findsNothing);
    expect(find.text('settings.ai_service'.tr), findsOneWidget);
  });

  testWidgets('เริ่มต้นเป็น Claude: มีแค่ช่อง key ไม่มีที่อยู่ API / รุ่น กดบันทึกส่ง provider claude', (tester) async {
    await pumpSection(tester, const AssistantState(ai: free));
    expect(find.text('settings.ai_provider_claude'.tr), findsOneWidget);
    expect(find.text('settings.ai_key'.tr), findsOneWidget);
    expect(find.text('settings.ai_base_url'.tr), findsNothing);
    expect(find.text('settings.ai_model'.tr), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'sk-ant-api03-test');
    await tester.tap(find.text('settings.ai_save'.tr));
    expect(savedSettings(), const AiSettingsModel(provider: AiStatusModel.claude, apiKey: 'sk-ant-api03-test'));
  });

  testWidgets('เลือก OpenAI ในช่องเดียวกัน: ขึ้นที่อยู่ API + รุ่น / เปลี่ยนเป็น Typhoon ที่อยู่เปลี่ยนตาม', (
    tester,
  ) async {
    await pumpSection(tester, const AssistantState(ai: free));
    await chooseOpenAi(tester);
    expect(find.text('https://api.openai.com/v1'), findsOneWidget);
    expect(find.text('settings.ai_model'.tr), findsOneWidget);

    await chooseProvider(tester, 'OpenAI (ChatGPT)', 'Typhoon (${'ai_preset.typhoon_note'.tr})');
    expect(find.text('https://api.opentyphoon.ai/v1'), findsOneWidget);
  });

  testWidgets('เลือกกลับเป็น Claude: ช่องที่อยู่ API / รุ่นหายไป', (tester) async {
    await pumpSection(tester, const AssistantState(ai: free));
    await chooseOpenAi(tester);
    await chooseProvider(tester, 'OpenAI (ChatGPT)', 'settings.ai_provider_claude'.tr);
    expect(find.text('settings.ai_key'.tr), findsOneWidget);
    expect(find.text('settings.ai_base_url'.tr), findsNothing);
  });

  testWidgets('กดดึงรายชื่อรุ่น ส่งที่อยู่ + key ไปให้ bloc', (tester) async {
    await pumpSection(tester, const AssistantState(ai: free));
    await chooseOpenAi(tester);
    await tester.enterText(find.widgetWithText(TextField, 'sk-...'), 'sk-openai');
    await tester.tap(find.text('settings.ai_fetch_models'.tr));
    final event =
        verify(() => bloc.add(captureAny(that: isA<AssistantModelsRequested>()))).captured.last
            as AssistantModelsRequested;
    expect([event.baseUrl, event.apiKey], ['https://api.openai.com/v1', 'sk-openai']);
  });

  testWidgets('พิมพ์ในช่องรุ่น ขึ้นรายชื่อที่ตรง กดเลือกแล้วบันทึกได้ครบ', (tester) async {
    await pumpSection(
      tester,
      const AssistantState(ai: free, models: ['gpt-mini', 'gpt-large', 'o-model'], modelsStatus: AppStatus.success),
    );
    await chooseOpenAi(tester);
    expect(find.text('settings.ai_models_found'.trParams({'count': '3'})), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'sk-...'), 'sk-openai');
    await tester.enterText(find.widgetWithText(TextFormField, 'settings.ai_model_hint'.tr), 'gpt');
    await tester.pumpAndSettle();
    expect(find.text('o-model'), findsNothing);
    await tester.tap(find.text('gpt-large'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('settings.ai_save'.tr));
    expect(
      savedSettings(),
      const AiSettingsModel(
        provider: AiStatusModel.openai,
        apiKey: 'sk-openai',
        baseUrl: 'https://api.openai.com/v1',
        model: 'gpt-large',
      ),
    );
  });

  testWidgets('ร้านตั้ง DeepSeek ไว้แล้ว: เปิดมาเลือก DeepSeek ไว้ ใส่ค่าเดิมให้ + บอกที่ใช้อยู่', (tester) async {
    await pumpSection(tester, const AssistantState(ai: deepSeek));
    expect(find.text('deepseek-chat (api.deepseek.com)'), findsOneWidget);
    expect(find.text('https://api.deepseek.com/v1'), findsOneWidget);
    expect(find.text('deepseek-chat'), findsOneWidget);
    expect(find.text('DeepSeek'), findsOneWidget);
    expect(find.text('settings.ai_remove'.tr), findsOneWidget);
  });

  testWidgets('บันทึกไม่ผ่าน แสดงข้อความ error', (tester) async {
    await pumpSection(
      tester,
      const AssistantState(ai: free, keyStatus: AppStatus.failure, keyErrorCode: 'ai_model_not_found'),
    );
    expect(find.text('error.ai_model_not_found'.tr), findsOneWidget);
  });
}
