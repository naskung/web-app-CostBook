import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/features/cost/bloc/cost_bloc.dart';
import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';
import 'package:costbook/features/cost/widgets/cost_presets_dialog.dart';

class MockCostBloc extends MockBloc<CostEvent, CostState> implements CostBloc {}

void main() {
  late MockCostBloc bloc;
  const pla = CostPresetModel(id: 'pr1', type: CostItemModel.material, name: 'เส้น PLA', unit: 'กรัม', unitPrice: 0.45);
  const labor = CostPresetModel(id: 'pr2', type: CostItemModel.labor, name: 'ค่าแรง', unit: 'นาที', unitPrice: 1);

  setUpAll(() async {
    await AppLang.load('th');
    registerFallbackValue(CostPageOpened());
  });

  setUp(() {
    bloc = MockCostBloc();
    when(() => bloc.state).thenReturn(const CostState(status: AppStatus.success, presets: [pla, labor]));
  });

  Future<void> pumpDialog(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: BlocProvider<CostBloc>.value(value: bloc, child: const CostPresetsDialog())),
      ),
    );
  }

  testWidgets('ชื่อใหม่ "ค่าใช้จ่ายเพิ่มเติม" + วัตถุดิบเดิมมีคำแนะนำให้ย้ายไปสต็อก', (tester) async {
    await pumpDialog(tester);
    expect(find.text('cost.presets_title'.tr), findsOneWidget);
    expect(find.text('cost.presets_material_notice'.tr), findsOneWidget);
    expect(find.byTooltip('cost.preset_move'.tr), findsOneWidget);
  });

  testWidgets('กดย้ายไปสต็อก → ถามยืนยัน → ส่ง CostPresetMovedToStock', (tester) async {
    await pumpDialog(tester);
    await tester.tap(find.byTooltip('cost.preset_move'.tr));
    await tester.pumpAndSettle();
    expect(find.text('cost.preset_move_title'.tr), findsOneWidget);
    await tester.tap(find.text('cost.preset_move'.tr).last);
    await tester.pumpAndSettle();
    final event =
        verify(() => bloc.add(captureAny(that: isA<CostPresetMovedToStock>()))).captured.single
            as CostPresetMovedToStock;
    expect(event.preset, pla);
  });

  testWidgets('ไม่มีวัตถุดิบเหลือในค่าใช้จ่ายเพิ่มเติม ไม่มีคำแนะนำ / ปุ่มย้าย', (tester) async {
    when(() => bloc.state).thenReturn(const CostState(status: AppStatus.success, presets: [labor]));
    await pumpDialog(tester);
    expect(find.text('cost.presets_material_notice'.tr), findsNothing);
    expect(find.byTooltip('cost.preset_move'.tr), findsNothing);
  });
}
