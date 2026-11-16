import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/transaction/bloc/transaction_bloc.dart';
import 'package:costbook/features/transaction/models/transaction_model.dart';
import 'package:costbook/features/transaction/models/transaction_summary_model.dart';
import 'package:costbook/features/transaction/repository/transaction_repository.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository repository;

  final october = DateTimeRange(start: DateTime(2026, 10), end: DateTime(2026, 10, 31));
  final november = DateTimeRange(start: DateTime(2026, 11, 1), end: DateTime(2026, 11, 15));
  const rent = TransactionModel(id: 't1', type: 'expense', category: 'rent', amount: 5000, date: '2026-10-01');
  const summary = TransactionSummaryModel(income: 8000, expense: 5000, profit: 3000);

  setUpAll(() {
    registerFallbackValue(rent);
    registerFallbackValue(DateTimeRange(start: DateTime(2026), end: DateTime(2026)));
  });

  setUp(() {
    repository = MockTransactionRepository();
    when(() => repository.getTransactions(any())).thenAnswer((_) async => [rent]);
    when(() => repository.getSummary(any())).thenAnswer((_) async => summary);
  });

  TransactionBloc buildBloc() => TransactionBloc(repository, range: october);

  blocTest<TransactionBloc, TransactionState>(
    'TransactionsRequested โหลดรายการและยอดสรุปของเดือน',
    build: buildBloc,
    act: (bloc) => bloc.add(TransactionsRequested()),
    expect:
        () => [
          TransactionState(range: october, status: AppStatus.loading),
          TransactionState(range: october, status: AppStatus.success, transactions: const [rent], summary: summary),
        ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionsRequested ล้มเหลว ได้ failure พร้อม code',
    build: () {
      when(() => repository.getTransactions(any())).thenThrow(ApiException('network_error'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(TransactionsRequested()),
    expect:
        () => [
          TransactionState(range: october, status: AppStatus.loading),
          TransactionState(range: october, status: AppStatus.failure, errorCode: 'network_error'),
        ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionRangeChanged เปลี่ยนช่วงวันที่ แล้วโหลดของช่วงนั้น',
    build: buildBloc,
    act: (bloc) => bloc.add(TransactionRangeChanged(november)),
    expect:
        () => [
          TransactionState(range: november, status: AppStatus.loading),
          TransactionState(range: november, status: AppStatus.success, transactions: const [rent], summary: summary),
        ],
    verify: (_) => verify(() => repository.getTransactions(november)).called(1),
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionSaved สำเร็จ บันทึกแล้วโหลดเดือนนั้นใหม่',
    build: () {
      when(() => repository.saveTransaction(any())).thenAnswer((_) async {});
      return buildBloc();
    },
    act: (bloc) => bloc.add(TransactionSaved(rent)),
    expect:
        () => [
          TransactionState(range: october, saveStatus: AppStatus.loading),
          TransactionState(range: october, saveStatus: AppStatus.success),
          TransactionState(
            range: october,
            status: AppStatus.success,
            transactions: const [rent],
            summary: summary,
            saveStatus: AppStatus.success,
          ),
        ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionSaved จำนวนเงินผิด ได้ saveStatus failure',
    build: () {
      when(() => repository.saveTransaction(any())).thenThrow(ApiException('transaction_amount_invalid'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(TransactionSaved(rent)),
    expect:
        () => [
          TransactionState(range: october, saveStatus: AppStatus.loading),
          TransactionState(range: october, saveStatus: AppStatus.failure, saveErrorCode: 'transaction_amount_invalid'),
        ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionDeleted รายการจากใบกำกับ ได้ deleteStatus failure',
    build: () {
      when(() => repository.deleteTransaction('t1')).thenThrow(ApiException('transaction_from_invoice'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(TransactionDeleted('t1')),
    expect:
        () => [
          TransactionState(range: october, deleteStatus: AppStatus.loading),
          TransactionState(
            range: october,
            deleteStatus: AppStatus.failure,
            deleteErrorCode: 'transaction_from_invoice',
          ),
        ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionDeleted สำเร็จ ลบแล้วโหลดใหม่',
    build: () {
      when(() => repository.deleteTransaction('t1')).thenAnswer((_) async {});
      when(() => repository.getTransactions(any())).thenAnswer((_) async => []);
      return buildBloc();
    },
    act: (bloc) => bloc.add(TransactionDeleted('t1')),
    expect:
        () => [
          TransactionState(range: october, deleteStatus: AppStatus.loading),
          TransactionState(range: october, deleteStatus: AppStatus.success),
          TransactionState(
            range: october,
            status: AppStatus.success,
            summary: summary,
            deleteStatus: AppStatus.success,
          ),
        ],
  );

  // รายการที่ n (id ไม่ซ้ำ)
  TransactionModel transactionAt(int n) {
    return TransactionModel(id: 'x$n', type: 'expense', category: 'other', amount: 10, date: '2026-10-01');
  }

  final loaded45 = [for (var n = 1; n <= 45; n++) transactionAt(n)];

  blocTest<TransactionBloc, TransactionState>(
    'บันทึกตอนเลื่อนโหลดไว้แล้ว 45 รายการ → โหลดใหม่ 45 รายการ (รายการไม่หดกลับเหลือ 20)',
    build: () {
      when(() => repository.saveTransaction(any())).thenAnswer((_) async {});
      when(() => repository.getTransactions(any(), limit: any(named: 'limit'))).thenAnswer((_) async => loaded45);
      when(() => repository.getSummary(any())).thenAnswer((_) async => summary);
      return TransactionBloc(repository, range: october);
    },
    seed: () => TransactionState(range: october, status: AppStatus.success, transactions: loaded45, hasMore: true),
    act: (bloc) => bloc.add(TransactionSaved(rent)),
    verify: (bloc) {
      verify(() => repository.getTransactions(october, limit: 45)).called(1);
      expect(bloc.state.hasMore, true);
    },
  );

  blocTest<TransactionBloc, TransactionState>(
    'เลื่อนลงโหลดหน้าต่อไป ต่อท้าย (ตัวที่มีอยู่แล้วไม่ซ้ำ) ได้น้อยกว่า 20 = หมดแล้ว',
    build: () {
      when(
        () => repository.getTransactions(any(), offset: 20),
      ).thenAnswer((_) async => [transactionAt(20), transactionAt(21)]);
      return TransactionBloc(repository, range: october);
    },
    seed:
        () => TransactionState(
          range: october,
          status: AppStatus.success,
          transactions: loaded45.take(20).toList(),
          hasMore: true,
        ),
    act: (bloc) => bloc.add(TransactionsMoreRequested()),
    skip: 1,
    expect:
        () => [
          TransactionState(
            range: october,
            status: AppStatus.success,
            transactions: loaded45.take(21).toList(),
            moreStatus: AppStatus.success,
          ),
        ],
  );
}
