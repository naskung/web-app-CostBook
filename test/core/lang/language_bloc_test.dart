import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/lang/language_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLang.load('th');
  });

  blocTest<LanguageBloc, String>(
    'เปลี่ยนเป็นภาษาอังกฤษ ได้ state en และข้อความเปลี่ยนเป็นภาษาอังกฤษ',
    build: LanguageBloc.new,
    act: (bloc) => bloc.add(ChangeLanguage('en')),
    expect: () => ['en'],
    verify: (_) => expect('menu.products'.tr, 'Products'),
  );

  test('เปลี่ยนภาษาแล้ว จำไว้ในเครื่อง เปิดแอปครั้งหน้าได้ภาษาเดิม', () async {
    final bloc = LanguageBloc()..add(ChangeLanguage('en'));
    await expectLater(bloc.stream, emits('en'));
    expect(await LanguageBloc.savedCode(), 'en');
    await bloc.close();
  });

  test('ยังไม่เคยเลือกภาษา ได้ภาษาไทย', () async {
    expect(await LanguageBloc.savedCode(), 'th');
  });
}
