import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:costbook/core/routes/app_page_transition.dart';

void main() {
  const pageKey = ValueKey('page');

  Future<void> pumpTransition(
    WidgetTester tester,
    Page<void> page, {
    required double enter,
    double exit = 0,
  }) async {
    final transitionPage = page as CustomTransitionPage<void>;
    await tester.pumpWidget(
      Builder(
        builder: (context) => transitionPage.transitionsBuilder(
          context,
          AlwaysStoppedAnimation(enter),
          AlwaysStoppedAnimation(exit),
          const SizedBox(),
        ),
      ),
    );
  }

  double enterScale(WidgetTester tester) {
    return tester.widget<ScaleTransition>(find.byType(ScaleTransition).first).scale.value;
  }

  double exitScale(WidgetTester tester) {
    return tester.widget<ScaleTransition>(find.byType(ScaleTransition).last).scale.value;
  }

  double enterOpacity(WidgetTester tester) {
    return tester.widget<FadeTransition>(find.byType(FadeTransition).first).opacity.value;
  }

  double exitOpacity(WidgetTester tester) {
    return tester.widget<FadeTransition>(find.byType(FadeTransition).last).opacity.value;
  }

  Page<void> forwardPage() => AppPageTransition.forward(key: pageKey, child: const SizedBox());

  Page<void> backwardPage() => AppPageTransition.backward(key: pageKey, child: const SizedBox());

  testWidgets('หน้าแบบเดินหน้า เข้ามาโดยเริ่มจากเล็ก (0.9) แล้วขยายเข้ามา', (tester) async {
    await pumpTransition(tester, forwardPage(), enter: 0);
    expect(enterScale(tester), AppPageTransition.forwardStartScale);
  });

  testWidgets('หน้าแบบถอยหลัง เข้ามาโดยเริ่มจากใหญ่ (1.1) แล้วย่อลงมา', (tester) async {
    await pumpTransition(tester, backwardPage(), enter: 0);
    expect(enterScale(tester), AppPageTransition.backwardStartScale);
  });

  testWidgets('เปลี่ยนหน้าเสร็จ ขนาดเต็มจอและเห็นชัด', (tester) async {
    await pumpTransition(tester, forwardPage(), enter: 1);
    expect(enterScale(tester), 1);
    expect(enterOpacity(tester), 1);
  });

  testWidgets('เริ่มเปลี่ยนหน้า หน้าใหม่ยังโปร่งใส', (tester) async {
    await pumpTransition(tester, forwardPage(), enter: 0);
    expect(enterOpacity(tester), 0);
  });

  testWidgets('หน้าแบบเดินหน้า ตอนถูกหน้าอื่นแทน หดเล็กลง (0.9) แล้วจางหาย', (tester) async {
    await pumpTransition(tester, forwardPage(), enter: 1, exit: 1);
    expect(exitScale(tester), AppPageTransition.forwardStartScale);
    expect(exitOpacity(tester), 0);
  });

  testWidgets('หน้าแบบถอยหลัง ตอนถูกหน้าอื่นแทน ขยายใหญ่ (1.1) แล้วจางหาย', (tester) async {
    await pumpTransition(tester, backwardPage(), enter: 1, exit: 1);
    expect(exitScale(tester), AppPageTransition.backwardStartScale);
    expect(exitOpacity(tester), 0);
  });

  test('ไปและกลับใช้เวลาเท่ากัน', () {
    final page = forwardPage() as CustomTransitionPage<void>;
    expect(page.transitionDuration, AppPageTransition.duration);
    expect(page.reverseTransitionDuration, AppPageTransition.duration);
  });

  testWidgets('go ไปหน้าใหม่ ระหว่างเปลี่ยน หน้าเก่าขยายและจางออก แล้วเหลือแค่หน้าใหม่', (tester) async {
    final router = GoRouter(
      initialLocation: '/a',
      routes: [
        GoRoute(
          path: '/a',
          pageBuilder: (context, state) => AppPageTransition.backward(key: state.pageKey, child: const Text('page-a')),
        ),
        GoRoute(
          path: '/b',
          pageBuilder: (context, state) => AppPageTransition.forward(key: state.pageKey, child: const Text('page-b')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    router.go('/b');
    await tester.pump();
    await tester.pump(AppPageTransition.duration ~/ 2);
    final oldPageExit = tester.widget<ScaleTransition>(
      find.ancestor(of: find.text('page-a'), matching: find.byType(ScaleTransition)).first,
    );
    expect(oldPageExit.scale.value, greaterThan(1));
    expect(find.text('page-b'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('page-a'), findsNothing);
    expect(find.text('page-b'), findsOneWidget);
  });
}
