import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:costbook/core/lang/app_lang.dart';
import 'package:costbook/core/routes/app_menu.dart';
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

  Future<void> pumpLayout(WidgetTester tester, Size screenSize, {String currentPath = AppRoutes.dashboard}) async {
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => ScreenScaler(child: child ?? const SizedBox()),
        home: PageLayout(
          title: 'menu.dashboard'.tr,
          menuItems: AppMenu.items,
          appName: 'app.name'.tr,
          logoutLabel: 'common.logout'.tr,
          menuButtonLabel: 'common.toggle_menu'.tr,
          currentPath: currentPath,
          onNavigate: navigatedRoutes.add,
          onLogout: () => logoutCount++,
          profile: const SideMenuProfile(
            name: 'สมชาย ใจดี',
            subtitle: 'เจ้าของร้าน',
            avatar: SizedBox.square(key: Key('avatar'), dimension: AppSizes.avatarSize),
            route: AppRoutes.profile,
          ),
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

  testWidgets('จอคอม เมนูหดอยู่ เมนูย่อยเป็นไอคอน กดรายการสินค้า ไปหน้า /products', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await toggleMenu(tester);
    await tester.tap(find.byIcon(Icons.list_alt));
    expect(navigatedRoutes, [AppRoutes.products]);
  });

  testWidgets('จอคอม เมนูหดอยู่ ชี้ไอคอนแล้วเห็นชื่อเมนูย่อย', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await toggleMenu(tester);
    expect(find.byTooltip('menu.product_list'.tr), findsOneWidget);
    expect(find.byTooltip('menu.stock_history'.tr), findsOneWidget);
  });

  testWidgets('มือถือ ซ่อนเมนูไว้ กดปุ่ม ☰ แล้วเมนูเลื่อนออกมา', (tester) async {
    await pumpLayout(tester, const Size(375, 667));
    expect(find.byType(AppSideMenu), findsNothing);
    await openDrawer(tester);
    expect(find.byType(AppSideMenu), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('แสดงชื่อเมนูหลักครบ 7 อัน และปุ่มออกจากระบบ / เมนูย่อยยังหุบอยู่', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    for (final key in [
      'menu.dashboard',
      'menu.sell',
      'menu.products',
      'menu.cost',
      'menu.transactions',
      'menu.invoices',
      'menu.settings',
    ]) {
      expect(menuLabel(key), findsOneWidget);
    }
    expect(menuLabel('menu.stock_history'), findsNothing);
    expect(find.text('common.logout'.tr), findsOneWidget);
  });

  testWidgets('อยู่หน้าประวัติสต็อก กลุ่มสินค้ากางเอง และเมนูย่อยนั้นเป็นสีส้ม', (tester) async {
    await pumpLayout(tester, const Size(1440, 900), currentPath: AppRoutes.stock);
    expect(menuLabel('menu.product_list'), findsOneWidget);
    final selectedTile = tester.widget<Material>(
      find.ancestor(of: menuLabel('menu.stock_history'), matching: find.byType(Material)).first,
    );
    expect(selectedTile.color, AppColors.primary);
  });

  testWidgets('เมนูของหน้าที่เปิดอยู่ เป็นสีส้ม', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    final selectedTile = tester.widget<Material>(
      find
          .ancestor(
            of: find.descendant(of: find.byType(AppSideMenu), matching: find.text('menu.dashboard'.tr)),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(selectedTile.color, AppColors.primary);
  });

  testWidgets('จอคอม กดกลุ่มสินค้า กางเมนูย่อย (ไม่เปลี่ยนหน้า) แล้วกดรายการสินค้า ไปหน้า /products', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await tester.tap(menuLabel('menu.products'));
    await tester.pumpAndSettle();
    expect(navigatedRoutes, isEmpty);
    await tester.tap(menuLabel('menu.product_list'));
    expect(navigatedRoutes, [AppRoutes.products]);
  });

  testWidgets('จอคอม กดกลุ่มที่กางอยู่อีกครั้ง เมนูย่อยหุบ', (tester) async {
    await pumpLayout(tester, const Size(1440, 900), currentPath: AppRoutes.stock);
    await tester.tap(menuLabel('menu.products'));
    await tester.pumpAndSettle();
    expect(menuLabel('menu.stock_history'), findsNothing);
  });

  testWidgets('มือถือ กางกลุ่มสินค้า กดประวัติสต็อก ไปหน้า /stock และปิดเมนู', (tester) async {
    await pumpLayout(tester, const Size(375, 667));
    await openDrawer(tester);
    await tester.tap(menuLabel('menu.products'));
    await tester.pumpAndSettle();
    await tester.tap(menuLabel('menu.stock_history'));
    await tester.pumpAndSettle();
    expect(navigatedRoutes, [AppRoutes.stock]);
    expect(find.byType(AppSideMenu), findsNothing);
  });

  testWidgets('กดออกจากระบบ เรียก onLogout', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await tester.tap(find.text('common.logout'.tr));
    expect(logoutCount, 1);
  });

  Material profileTile(WidgetTester tester) {
    return tester.widget<Material>(
      find.ancestor(of: find.byKey(const Key('avatar')), matching: find.byType(Material)).first,
    );
  }

  testWidgets('แถวผู้ใช้เหนือปุ่มออกจากระบบ มีชื่อ + ตำแหน่ง กดแล้วไปหน้าโปรไฟล์', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    expect(find.text('สมชาย ใจดี'), findsOneWidget);
    expect(find.text('เจ้าของร้าน'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('สมชาย ใจดี')).dy,
      lessThan(tester.getTopLeft(find.text('common.logout'.tr)).dy),
    );
    await tester.tap(find.text('สมชาย ใจดี'));
    expect(navigatedRoutes, [AppRoutes.profile]);
  });

  testWidgets('อยู่หน้าโปรไฟล์ หรือหน้าจัดการผู้ใช้ (ใต้โปรไฟล์) แถวผู้ใช้เป็นสีส้ม', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    expect(profileTile(tester).color, AppColors.transparent);

    await pumpLayout(tester, const Size(1440, 900), currentPath: AppRoutes.users);
    expect(profileTile(tester).color, AppColors.primary);
  });

  testWidgets('จอคอม เมนูหดอยู่ แถวผู้ใช้เหลือแต่รูป ชี้แล้วเห็นชื่อ', (tester) async {
    await pumpLayout(tester, const Size(1440, 900));
    await toggleMenu(tester);
    expect(find.text('สมชาย ใจดี'), findsNothing);
    expect(find.byKey(const Key('avatar')), findsOneWidget);
    expect(find.byTooltip('สมชาย ใจดี'), findsOneWidget);
  });
}
