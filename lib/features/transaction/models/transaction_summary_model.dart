import 'package:equatable/equatable.dart';

// สรุปเงินของเดือน (API คิดให้ ดู GET /transactions/summary)
// income / expense = เงินเข้า / ออกตามที่บันทึก — ไม่ใช่กำไร
// revenue = รายได้ (ยอดขายก่อน VAT + รายรับอื่น), profit = กำไรสุทธิ = revenue − costOfSales − operatingExpense
// operatingExpense ไม่รวมซื้อวัตถุดิบ (materialExpense) เพราะคิดอยู่ในต้นทุนสินค้าแล้ว
class TransactionSummaryModel extends Equatable {
  const TransactionSummaryModel({
    this.income = 0,
    this.expense = 0,
    this.sales = 0,
    this.otherIncome = 0,
    this.revenue = 0,
    this.costOfSales = 0,
    this.grossProfit = 0,
    this.materialExpense = 0,
    this.operatingExpense = 0,
    this.profit = 0,
  });

  final double income;
  final double expense;
  final double sales;
  final double otherIncome;
  final double revenue;
  final double costOfSales;
  final double grossProfit;
  final double materialExpense;
  final double operatingExpense;
  final double profit;

  factory TransactionSummaryModel.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num? ?? 0).toDouble();
    return TransactionSummaryModel(
      income: number('income'),
      expense: number('expense'),
      sales: number('sales'),
      otherIncome: number('other_income'),
      revenue: number('revenue'),
      costOfSales: number('cost_of_sales'),
      grossProfit: number('gross_profit'),
      materialExpense: number('material_expense'),
      operatingExpense: number('operating_expense'),
      profit: number('profit'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'income': income,
      'expense': expense,
      'sales': sales,
      'other_income': otherIncome,
      'revenue': revenue,
      'cost_of_sales': costOfSales,
      'gross_profit': grossProfit,
      'material_expense': materialExpense,
      'operating_expense': operatingExpense,
      'profit': profit,
    };
  }

  @override
  List<Object?> get props => [
    income,
    expense,
    sales,
    otherIncome,
    revenue,
    costOfSales,
    grossProfit,
    materialExpense,
    operatingExpense,
    profit,
  ];
}
