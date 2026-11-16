import 'package:flutter/material.dart' show DateTimeRange;
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

    test('toApiRange ได้ from / to สำหรับต่อท้าย URL', () {
      final range = DateTimeRange(start: DateTime(2026, 11, 1), end: DateTime(2026, 11, 16));
      expect(DateUtil.toApiRange(range), 'from=2026-11-01&to=2026-11-16');
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
      expect(DateUtil.yearLabel(2026), '2569');
      expect(DateUtil.monthLabel(DateTime(2026, 10)), 'ตุลาคม 2569');
    });

    test('ชื่อเดือนแบบสั้นในกราฟ ต.ค.', () {
      expect(DateUtil.shortMonthLabel(DateTime(2026, 10)), 'ต.ค.');
    });

    test('ภาษาอังกฤษ แสดงปี ค.ศ.', () async {
      await AppLang.load('en');
      expect(DateUtil.yearLabel(2026), '2026');
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

  group('DateUtil ช่วงวันที่', () {
    DateTimeRange range(DateTime start, DateTime end) => DateTimeRange(start: start, end: end);

    test('monthRange ได้วันแรกถึงวันสุดท้ายของเดือน (ก.พ. ปีอธิกสุรทิน 29 วัน)', () {
      expect(DateUtil.monthRange(DateTime(2026, 11, 16, 15, 30)), range(DateTime(2026, 11, 1), DateTime(2026, 11, 30)));
      expect(DateUtil.monthRange(DateTime(2028, 2, 10)), range(DateTime(2028, 2, 1), DateTime(2028, 2, 29)));
    });

    test('dayRange ตัดเวลาออก ได้วันเดียว', () {
      expect(DateUtil.dayRange(DateTime(2026, 11, 16, 15, 30)), range(DateTime(2026, 11, 16), DateTime(2026, 11, 16)));
    });

    test('lastDays 7 วันล่าสุด รวมวันนี้ ข้ามเดือนได้', () {
      expect(DateUtil.lastDays(DateTime(2026, 11, 3), 7), range(DateTime(2026, 10, 28), DateTime(2026, 11, 3)));
    });

    test('dayCount นับรวมทั้ง 2 วัน', () {
      expect(DateUtil.dayCount(range(DateTime(2026, 11, 16), DateTime(2026, 11, 16))), 1);
      expect(DateUtil.dayCount(range(DateTime(2026, 11, 1), DateTime(2026, 11, 30))), 30);
      expect(DateUtil.dayCount(range(DateTime(2028, 1, 1), DateTime(2028, 12, 31))), 366);
    });

    test('isInRange นับวันแรกและวันสุดท้ายด้วย ไม่สนเวลา', () {
      final november = range(DateTime(2026, 11, 1), DateTime(2026, 11, 15));
      expect(DateUtil.isInRange(DateTime(2026, 11, 1), november), isTrue);
      expect(DateUtil.isInRange(DateTime(2026, 11, 15, 23, 59), november), isTrue);
      expect(DateUtil.isInRange(DateTime(2026, 11, 16), november), isFalse);
      expect(DateUtil.isInRange(DateTime(2026, 10, 31), november), isFalse);
    });

    test('daysUntil นับถึงวันนี้ถ้าวันนี้อยู่ในช่วง / ช่วงที่ผ่านไปแล้วได้ทั้งช่วง / ช่วงในอนาคตได้ 0', () {
      final november = range(DateTime(2026, 11, 1), DateTime(2026, 11, 30));
      expect(DateUtil.daysUntil(november, DateTime(2026, 11, 16, 9)), 16);
      expect(DateUtil.daysUntil(november, DateTime(2026, 12, 5)), 30);
      expect(DateUtil.daysUntil(november, DateTime(2026, 10, 5)), 0);
    });

    test('defaultDateIn วันนี้อยู่ในช่วง ได้วันนี้ / ไม่อยู่ ได้วันแรกของช่วง', () {
      final october = range(DateTime(2026, 10, 1), DateTime(2026, 10, 31));
      expect(DateUtil.defaultDateIn(october, DateTime(2026, 10, 20, 8)), DateTime(2026, 10, 20));
      expect(DateUtil.defaultDateIn(october, DateTime(2026, 11, 16)), DateTime(2026, 10, 1));
    });

    test('rangeLabel ทั้งเดือน / วันเดียว / เดือนเดียวกัน / ข้ามเดือน / ข้ามปี', () {
      expect(DateUtil.rangeLabel(range(DateTime(2026, 11, 1), DateTime(2026, 11, 30))), 'พฤศจิกายน 2569');
      expect(DateUtil.rangeLabel(range(DateTime(2026, 11, 16), DateTime(2026, 11, 16))), '16 พ.ย. 2569');
      expect(DateUtil.rangeLabel(range(DateTime(2026, 11, 1), DateTime(2026, 11, 15))), '1 – 15 พ.ย. 2569');
      expect(DateUtil.rangeLabel(range(DateTime(2026, 10, 17), DateTime(2026, 11, 16))), '17 ต.ค. – 16 พ.ย. 2569');
      expect(DateUtil.rangeLabel(range(DateTime(2025, 12, 20), DateTime(2026, 1, 5))), '20 ธ.ค. 2568 – 5 ม.ค. 2569');
    });

    test('calendarDays เริ่มวันอาทิตย์ ช่องก่อนวันที่ 1 เป็น null', () {
      final days = DateUtil.calendarDays(DateTime(2026, 11));
      expect(days.first, DateTime(2026, 11, 1));
      expect(days.length, 30);

      final october = DateUtil.calendarDays(DateTime(2026, 10));
      expect(october.take(4), [null, null, null, null]);
      expect(october[4], DateTime(2026, 10, 1));
      expect(october.last, DateTime(2026, 10, 31));
    });
  });
}
