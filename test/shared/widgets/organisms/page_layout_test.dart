import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_routes.dart';
import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/theme/app_theme.dart';
import 'package:costbook/shared/widgets/organisms/app_side_menu.dart';
import 'package:costbook/shared/widgets/organisms/page_layout.dart';
import 'package:costbook/shared/widgets/organisms/screen_scaler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AppLang.load('th');
  });

  late List<String> navigatedRoutes;
  late int logoutCount;

  setUp(() {
    navigatedRoutes = [];
    logoutCount = 0;
  });

  Future<void> pumpLayout(WidgetTester tester, Size screenSize) async {
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => ScreenScaler(child: child ?? const SizedBox()),
        home: PageLayout(
          title: 'menu.dashboard'.tr,
          appName: 'app.name'.tr,
          logoutLabel: 'common.logout'.tr,
          menuButtonLabel: 'common.toggle_menu'.tr,
          currentPath: AppRoutes.dashboard,
          onNavigate: navigatedRoutes.add,
          onLogout: () => logoutCount++,
          child: const Text('page-content'),
        ),
      ),
    );
  }

  Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
  }

  final screenSizes = {
    'มือถือเล็ก 320x568': const Size(320, 568),
    'แท็บเล็ต 768x1024': const Size(768, 1024),
    'จอคอม 1024x768': const Size(1024, 768),
    'จอคอม 1440x900': const Size(1440, 900),
    'จอใหญ่ 2560x1440': const Size(2560, 1440),
  };

  screenSizes.forEach((name, size) {
    testWidgets('$name แสดงหน้าได้ไม่ล้นจอ', (tester) async {
      await pumpLayout(tester, size);
      expect(tester.takeException(), isNull);
      expect(find.text('page-content'), findsOneWidget);
    });
  });

  double sideMenuWidth(WidgetTester tester) => tester.getSize(find.byType(AppSideMenu)).width;

  Finder menuLabel(String key) {
    return find.descendant(of: find.byType(AppSideMenu), matching: find.text(key.tr));
  }

  Future<void> toggleMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('common.toggle_menu'.tr));
    await tester.pumpAndSettle();
  }

  testWidgets('จอคอม เริ่มต้นเมนูกางเต็ม มีปุ่มเก็บเมนู', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    expect(sideMenuWidth(tester), AppSizes.sideMenuWidth);
    expect(find.byIcon(Icons.menu_open_rounded), findsOneWidget);
  });

  testWidgets('จอคอม กดปุ่ม ☰ เมนูหดเหลือแต่ไอคอน ชื่อเมนูหายไป', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await toggleMenu(tester);
    expect(sideMenuWidth(tester), AppSizes.sideMenuCollapsedWidth);
    expect(menuLabel('menu.products'), findsNothing);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('จอคอม เมนูหดอยู่ กดอีกครั้ง กางกลับมาพร้อมชื่อเมนู', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await toggleMenu(tester);
    await toggleMenu(tester);
    expect(sideMenuWidth(tester), AppSizes.sideMenuWidth);
    expect(menuLabel('menu.products'), findsOneWidget);
  });

  testWidgets('จอคอม ระหว่างเมนูกำลังหด / กาง ไม่ล้นจอ', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await tester.tap(find.byTooltip('common.toggle_menu'.tr));
    for (var i = 0; i < 10; i++) {
      await tester.pump(PageLayout.menuAnimationDuration ~/ 10);
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.byTooltip('common.toggle_menu'.tr));
    for (var i = 0; i < 10; i++) {
      await tester.pump(PageLayout.menuAnimationDuration ~/ 10);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('จอคอม เมนูหดอยู่ กดไอคอนสินค้า ไปหน้า /products', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await toggleMenu(tester);
    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    expect(navigatedRoutes, [AppRoutes.products]);
  });

  testWidgets('จอคอม เมนูหดอยู่ ชี้ไอคอนแล้วเห็นชื่อเมนู', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await toggleMenu(tester);
    expect(find.byTooltip('menu.products'.tr), findsOneWidget);
  });

  testWidgets('มือถือ ซ่อนเมนูไว้ กดปุ่ม ☰ แล้วเมนูเลื่อนออกมา', (tester) async {
    await pumpLayout(tester, const Size(375, 667));
    expect(find.byType(AppSideMenu), findsNothing);
    await openDrawer(tester);
    expect(find.byType(AppSideMenu), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('แสดงชื่อเมนูครบ 7 หน้า และปุ่มออกจากระบบ', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    for (final key in [
      'menu.dashboard',
      'menu.products',
      'menu.cost',
      'menu.stock',
      'menu.transactions',
      'menu.invoices',
      'menu.settings',
    ]) {
      expect(find.descendant(of: find.byType(AppSideMenu), matching: find.text(key.tr)), findsOneWidget);
    }
    expect(find.text('common.logout'.tr), findsOneWidget);
  });

  testWidgets('เมนูของหน้าที่เปิดอยู่ เป็นสีส้ม', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    final selectedTile = tester.widget<Material>(
      find.ancestor(
        of: find.descendant(of: find.byType(AppSideMenu), matching: find.text('menu.dashboard'.tr)),
        matching: find.byType(Material),
      ).first,
    );
    expect(selectedTile.color, AppColors.primary);
  });

  testWidgets('จอคอม กดเมนูสินค้า ไปหน้า /products', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await tester.tap(find.text('menu.products'.tr));
    expect(navigatedRoutes, [AppRoutes.products]);
  });

  testWidgets('มือถือ กดเมนูสต็อก ไปหน้า /stock และปิดเมนู', (tester) async {
    await pumpLayout(tester, const Size(375, 667));
    await openDrawer(tester);
    await tester.tap(find.text('menu.stock'.tr));
    await tester.pumpAndSettle();
    expect(navigatedRoutes, [AppRoutes.stock]);
    expect(find.byType(AppSideMenu), findsNothing);
  });

  testWidgets('กดออกจากระบบ เรียก onLogout', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await tester.tap(find.text('common.logout'.tr));
    expect(logoutCount, 1);
  });
}
