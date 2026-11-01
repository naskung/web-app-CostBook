import 'package:costbook/core/utils/money_util.dart';

class CashUtil {
  // ปัดขึ้นเป็นเลขกลม ๆ ที่ลูกค้ามักให้ (แบงก์ 50 / 100 / 500 / 1,000)
  static const List<double> _roundSteps = [50, 100, 500, 1000];

  // ปุ่มลัดตอนรับเงิน: พอดี + ยอดที่ปัดขึ้นเป็นเลขกลม (มากกว่ายอดจริง ไม่ซ้ำ เรียงน้อยไปมาก)
  // เช่น 349.52 → 349.52, 350, 400, 500, 1000
  static List<double> quickAmounts(double total) {
    final amounts = [MoneyUtil.round2(total)];
    for (final step in _roundSteps) {
      final rounded = (total / step).ceil() * step;
      if (rounded > total && !amounts.contains(rounded)) amounts.add(rounded);
    }
    return amounts;
  }

  // เงินทอน (ติดลบ = เงินไม่พอ)
  static double change(double received, double total) => MoneyUtil.round2(received - total);
}
