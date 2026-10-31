import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/utils/date_util.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppLang.load('th');
  });

  group('DateUtil', () {
    test('toApiDate 5 มี.ค. 2026 ได้ 2026-03-05', () {
      expect(DateUtil.toApiDate(DateTime(2026, 3, 5)), '2026-03-05');
    });

    test('toApiMonth ต.ค. 2026 ได้ 2026-10', () {
      expect(DateUtil.toApiMonth(DateTime(2026, 10, 31)), '2026-10');
    });

    test('fromApiDate อ่าน 2026-10-31 ได้วันที่ถูก', () {
      expect(DateUtil.fromApiDate('2026-10-31'), DateTime(2026, 10, 31));
    });

    test('fromApiDate ข้อความผิด ไม่ error', () {
      expect(DateUtil.fromApiDate('abc'), DateTime(1970));
    });

    test('ภาษาไทย แสดงวันที่เป็น พ.ศ. 31/10/2569', () {
      expect(DateUtil.toDisplayDate(DateTime(2026, 10, 31)), '31/10/2569');
    });

    test('ภาษาไทย ชื่อเดือนตุลาคม 2569', () {
      expect(DateUtil.monthLabel(DateTime(2026, 10)), 'ตุลาคม 2569');
    });

    test('ภาษาอังกฤษ แสดงปี ค.ศ.', () async {
      await AppLang.load('en');
      expect(DateUtil.toDisplayDate(DateTime(2026, 10, 31)), '31/10/2026');
      expect(DateUtil.monthLabel(DateTime(2026, 10)), 'October 2026');
    });

    test('addMonths ธ.ค. 2026 + 1 เดือน ได้ ม.ค. 2027', () {
      expect(DateUtil.addMonths(DateTime(2026, 12), 1), DateTime(2027, 1));
    });

    test('addMonths ม.ค. 2026 - 1 เดือน ได้ ธ.ค. 2025', () {
      expect(DateUtil.addMonths(DateTime(2026, 1), -1), DateTime(2025, 12));
    });
  });
}
