# CostBook Web App — โครงสร้างโปรเจกต์

> ไฟล์นี้คือ **กติกากลาง** ของโปรเจกต์ ทุกคน (รวมถึง Claude) ต้องทำตามนี้
> ถ้าจะเปลี่ยนกติกา ให้แก้ไฟล์นี้ก่อน แล้วค่อยแก้โค้ด
> หลักสำคัญที่สุด: **เขียนให้ง่าย (simple)** ดู `.claude/skills/simple-code/SKILL.md`

---

## 1. แอปนี้ทำอะไร

| Feature | ทำอะไร | Route |
|---|---|---|
| auth | เข้าสู่ระบบด้วยอีเมล + รหัสผ่าน (API `POST /api/v1/auth/login`) | `/login` |
| dashboard | สรุปรายรับ-รายจ่าย กำไร และสินค้าใกล้หมด | `/` |
| product | จัดการสินค้า (ชื่อ, หน่วย, ราคาทุน, ราคาขาย, จำนวนขั้นต่ำ) | `/products` |
| cost | คำนวณต้นทุนต่อหน่วย และราคาขายจาก % markup | `/cost` |
| stock | ดูจำนวนคงเหลือ รับเข้า / เบิกออก แจ้งเตือนสินค้าใกล้หมด | `/stock` |
| transaction | บันทึกรายรับ-รายจ่าย แยกหมวด และสรุปรายเดือน | `/transactions` |
| invoice | สร้างใบกำกับภาษี คิด VAT 7% พิมพ์ / ดาวน์โหลด PDF | `/invoices` |
| settings | ข้อมูลบริษัท (ชื่อ ที่อยู่ เลขผู้เสียภาษี สาขา) และเปลี่ยนภาษา | `/settings` |

Backend อยู่ที่ repo `../api-Costbook` — ระหว่างที่ API ยังไม่เสร็จ ให้ repository คืนข้อมูลตัวอย่างไปก่อน (ใส่ `// TODO: ต่อ API`)

- `ApiConstants.baseUrl = 'http://localhost:8080/api/v1'`
- โลโก้ร้าน: `ApiConstants.companyLogoUrl` (`GET /company/logo` ไม่ต้อง login) ใช้ 2 ที่ — หน้า login (`Image.network`, โหลดไม่ได้ / ร้านยังไม่มีโลโก้ → ไอคอน CostBook สีส้มแทน) และ favicon ใน `web/index.html` (เขียน URL ตรง ๆ เพราะ favicon โหลดก่อน Flutter เริ่ม)
  - เปลี่ยน `baseUrl` → ต้องแก้ URL favicon ใน `web/index.html` ด้วย (`test/core/constants/api_constants_test.dart` เช็คว่า 2 ที่ตรงกัน ลืมแก้ test ไม่ผ่าน)
- endpoint, ชื่อ field ใน JSON และรูปแบบ error ดูที่ `../api-Costbook/docs/ARCHITECTURE.md` หัวข้อ 6–7

---

## 2. เทคโนโลยีที่ใช้

| Package | ใช้ทำอะไร |
|---|---|
| `flutter_bloc` | จัดการ state (BLoC) |
| `equatable` | เปรียบเทียบ state / model (จำเป็นตอนเขียน test) |
| `go_router` | route และ URL ของเว็บ |
| `http` | เรียก API |
| `shared_preferences` | เก็บ token ไว้ในเครื่องเมื่อติ๊ก "จดจำการเข้าสู่ระบบ" (บนเว็บคือ localStorage ของ browser) |
| `intl` | format ตัวเลข / เงิน / วันที่ |
| `pdf`, `printing` | สร้างและพิมพ์ใบกำกับภาษี |
| `bloc_test`, `mocktail` (dev) | เขียน unit test ของ bloc |

เพิ่มครบทุกตัวแล้ว (2026-10-31)

**`dependency_overrides: image: 4.5.4` ใน `pubspec.yaml` ห้ามลบ** — `pdf` ดึง `image` 4.11 มา ซึ่งเรียก method ที่ `archive` 4.0.9 (เวอร์ชันล่าสุดที่ใช้กับ Flutter 3.35 ได้) ยังไม่มี → compile ไม่ผ่าน ลบได้เมื่ออัปเกรด Flutter แล้ว `flutter pub get` ได้ `archive` ใหม่กว่า 4.0.9

**ไม่ใช้:** GetX, get_it, freezed, json_serializable, build_runner (เหตุผล: อยากให้โค้ดง่าย)
ภาษาแบบ `.tr` เราเขียนเอง ไม่ต้องใช้ GetX (ดูหัวข้อ 10)

```bash
# สร้างโปรเจกต์ในโฟลเดอร์นี้ (ชื่อโฟลเดอร์มี - จึงต้องกำหนด project-name เอง)
flutter create --platforms web --project-name costbook .

flutter pub add flutter_bloc equatable go_router http shared_preferences intl pdf printing
flutter pub add dev:bloc_test dev:mocktail
```

---

## 3. โครงสร้างโฟลเดอร์

```
web-app-CostBook/
├── assets/
│   ├── lang/              th.json, en.json
│   ├── fonts/             LINESeedSansTH (ฟอนต์หลักของแอป ลงทะเบียนใน pubspec.yaml)
│   └── images/            รูปที่ใช้ทุกร้าน (โลโก้ร้านไม่ฝังในแอป — แต่ละร้านต่างกัน มาจากข้อมูลร้านในหน้า settings)
├── lib/
│   ├── main.dart          จุดเริ่มแอป: โหลดภาษาที่เลือกไว้ + อ่าน token ที่จดจำไว้ + ตั้ง ApiClient.onUnauthorized แล้ว runApp
│   ├── app.dart           LanguageBloc + MaterialApp.router (key = รหัสภาษา → เปลี่ยนภาษาแล้วข้อความเปลี่ยนทั้งแอป)
│   ├── core/
│   │   ├── constants/     app_status.dart, screen_type.dart, api_constants.dart (baseUrl, companyLogoUrl)
│   │   ├── lang/          app_lang.dart (.tr), language_bloc.dart (เปลี่ยน + จำภาษา)
│   │   ├── network/       api_client.dart (get / post / put / delete + token + 401), api_exception.dart (error code จาก API)
│   │   ├── routes/        app_routes.dart (ชื่อ route), app_router.dart (GoRouter + สร้าง bloc ของแต่ละหน้า), app_menu.dart, app_shell.dart, app_page_transition.dart
│   │   ├── theme/         app_colors.dart (สี), app_sizes.dart (ขนาดตัวอักษร / ระยะห่าง), app_theme.dart (ฟอนต์ + รวมเป็น ThemeData)
│   │   ├── utils/         money_util, tax_util, cost_util, date_util, validator_util, error_util, responsive_util
│   │   └── helpers/       dialog_helper.dart (ถามยืนยัน), snackbar_helper.dart, pdf_helper.dart (พิมพ์ / ดาวน์โหลด PDF), responsive_helper.dart
│   ├── shared/
│   │   └── widgets/
│   │       ├── atoms/       app_button, app_text_field, app_dropdown, app_loading, app_badge, money_text, shop_logo
│   │       ├── molecules/   empty_view, error_view, stat_card, month_switcher, search_field, section_card, notice_banner
│   │       └── organisms/   page_layout, app_side_menu, screen_scaler, page_content (ขอบ + ความกว้างหน้า), page_toolbar,
│   │                        app_data_table (จอคอม = ตาราง / มือถือ = การ์ด), form_dialog (กล่องฟอร์ม), stat_grid
│   └── features/          ทุก feature: models → repository → bloc → pages (+ _ext ถ้ายาว) → widgets
│       ├── auth/            login + จดจำ token / อีเมล
│       ├── dashboard/       ตัวเลขสรุปของเดือน + สินค้าใกล้หมด + ทางลัด
│       ├── product/         รายการ / ค้นหา / เพิ่ม / แก้ / ลบสินค้า (widgets/product_form_dialog.dart)
│       ├── cost/            ใบต้นทุนของสินค้า + markup → ราคาขาย (widgets/cost_item_dialog.dart)
│       ├── stock/           คงเหลือ / ใกล้หมด / ประวัติ / รับเข้า / เบิกออก (widgets/stock_movement_dialog.dart)
│       ├── transaction/     รายรับ-รายจ่ายรายเดือน + สรุป (widgets/transaction_form_dialog.dart)
│       ├── invoice/         bloc 3 ตัว: invoice_list / invoice_form / invoice_detail
│       │                    pages: invoice_list_page, invoice_form_page (+ _ext), invoice_detail_page
│       │                    widgets: invoice_item_row.dart (บรรทัดสินค้าในฟอร์ม), invoice_paper.dart (กระดาษใบกำกับ A4)
│       └── settings/        ข้อมูลร้าน + โลโก้ + เปลี่ยนภาษา
└── test/                  โครงเหมือน lib/ ทุกอย่าง เช่น test/core/utils/tax_util_test.dart
```

ทุก feature ใช้ 5 โฟลเดอร์เดียวกัน: `bloc / models / repository / pages / widgets` (ไม่มีอันไหนก็ไม่ต้องสร้าง)

### ไฟล์นี้ควรอยู่ไหน?

| ถ้าเป็นโค้ดที่... | วางที่ |
|---|---|
| คำนวณ / แปลงค่า ไม่ใช้ UI เลย | `core/utils/` |
| ต้องใช้ `BuildContext` หรือ plugin (dialog, snackbar, pdf) | `core/helpers/` |
| สี / ขนาดตัวอักษร / ระยะห่าง / ฟอนต์ | `core/theme/` |
| widget ที่ใช้มากกว่า 1 feature | `shared/widgets/` |
| widget ที่ใช้แค่ feature เดียว | `features/<ชื่อ>/widgets/` |
| เรียก API | `features/<ชื่อ>/repository/` |
| เก็บ state ของหน้าจอ | `features/<ชื่อ>/bloc/` |

---

## 4. การไหลของข้อมูล (Data flow)

```
Page ──(add Event)──▶ Bloc ──▶ Repository ──▶ ApiClient ──▶ api-Costbook
 ▲                     │
 └────(emit State)─────┘
```

- Page **ไม่** เรียก repository ตรง ๆ — ส่ง event ให้ bloc เท่านั้น
- Bloc **ไม่** import widget และไม่ใช้ `BuildContext`
- Repository คืนค่าเป็น **Model** เสมอ (ไม่คืน `Map`)
- การคำนวณ (ต้นทุน, VAT) อยู่ใน `core/utils` — bloc และ page เรียกใช้

---

## 5. Model

- 1 ไฟล์ 1 model, `extends Equatable`
- เขียน `fromJson` / `toJson` เอง (ไม่ใช้ code generation)
- ชื่อ key ใน JSON ให้ตรงกับ api-Costbook
- เพิ่ม `copyWith` เฉพาะตอนที่ต้องใช้จริง

```dart
// lib/features/product/models/product_model.dart
import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  const ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.costPrice,
    required this.sellPrice,
    required this.stock,
    required this.minStock,
  });

  final String id;
  final String name;
  final String unit; // หน่วย เช่น ชิ้น, กล่อง
  final double costPrice; // ราคาทุนต่อหน่วย
  final double sellPrice; // ราคาขายต่อหน่วย
  final int stock; // จำนวนคงเหลือ
  final int minStock; // เหลือเท่านี้หรือน้อยกว่า = ใกล้หมด

  bool get isLowStock => stock <= minStock;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      costPrice: (json['cost_price'] as num? ?? 0).toDouble(),
      sellPrice: (json['sell_price'] as num? ?? 0).toDouble(),
      stock: (json['stock'] as num? ?? 0).toInt(),
      minStock: (json['min_stock'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'cost_price': costPrice,
      'sell_price': sellPrice,
      'stock': stock,
      'min_stock': minStock,
    };
  }

  @override
  List<Object?> get props => [id, name, unit, costPrice, sellPrice, stock, minStock];
}
```

---

## 6. BLoC

ทุก bloc มี 3 ไฟล์: `xxx_bloc.dart`, `xxx_event.dart`, `xxx_state.dart` (event กับ state เป็น `part of` ของ bloc → import แค่ไฟล์ bloc ไฟล์เดียว)

State ใช้ **class เดียว** + `status` บอกสถานะ (ไม่แยกเป็นหลาย class)

```dart
// lib/core/constants/app_status.dart
enum AppStatus { initial, loading, success, failure }
```

```dart
// lib/features/product/bloc/product_event.dart
part of 'product_bloc.dart';

abstract class ProductEvent {}

class LoadProducts extends ProductEvent {}

class DeleteProduct extends ProductEvent {
  DeleteProduct(this.id);
  final String id;
}
```

```dart
// lib/features/product/bloc/product_state.dart
part of 'product_bloc.dart';

class ProductState extends Equatable {
  const ProductState({
    this.status = AppStatus.initial,
    this.products = const [],
    this.errorMessage = '',
  });

  final AppStatus status;
  final List<ProductModel> products;
  final String errorMessage;

  ProductState copyWith({
    AppStatus? status,
    List<ProductModel>? products,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage];
}
```

```dart
// lib/features/product/bloc/product_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc(this.repository) : super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
  }

  final ProductRepository repository;

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final products = await repository.getProducts();
      emit(state.copyWith(status: AppStatus.success, products: products));
    } catch (e) {
      emit(state.copyWith(status: AppStatus.failure, errorMessage: e.toString()));
    }
  }
}
```

```dart
// lib/features/product/repository/product_repository.dart
class ProductRepository {
  ProductRepository(this.api);

  final ApiClient api;

  Future<List<ProductModel>> getProducts() async {
    final data = await api.get('/products') as List;
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }
}
```

### สร้าง Bloc ที่ไหน

| Bloc แบบไหน | สร้างที่ |
|---|---|
| ใช้ทั้งแอป (ภาษา, ข้อมูลบริษัท) | `app.dart` |
| ใช้หน้าเดียว | ใน `builder` ของ route นั้น (ดูหัวข้อ 7) |

ไม่ใช้ get_it — สร้าง object ตรง ๆ เช่น `ProductBloc(ProductRepository(ApiClient()))`

---

## 7. Route

ชื่อ route ทุกตัวอยู่ใน `AppRoutes` ที่เดียว **ห้ามพิมพ์ path เป็น string ในหน้าจอ** — เพิ่ม / แก้สินค้า / รายการ ใช้กล่องฟอร์ม (dialog) ไม่มี route แยก

```dart
// lib/core/routes/app_routes.dart
class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/';
  static const String products = '/products';
  static const String cost = '/cost';
  static const String stock = '/stock';
  static const String transactions = '/transactions';
  static const String invoices = '/invoices';
  static const String invoiceCreate = '/invoices/create';
  static const String invoiceDetail = '/invoices/:id';
  static const String settings = '/settings';

  static String invoiceDetailPath(String id) => '/invoices/$id';
}
```

```dart
// lib/core/routes/app_router.dart
final appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    // ShellRoute = ทุกหน้ามีเมนูด้านข้าง + แถบบน เหมือนกัน (AppShell → PageLayout → AppSideMenu)
    ShellRoute(
      pageBuilder: (context, state, child) => AppPageTransition.forward(
        key: state.pageKey,
        child: BlocProvider(
          create: _createAuthBloc,
          child: AppShell(currentPath: state.uri.path, child: child),
        ),
      ),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: (context, state) => AppPageTransition.forward(
            key: state.pageKey,
            child: const DashboardPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.products,
          builder: (context, state) => BlocProvider(
            create: (_) => ProductBloc(ProductRepository(ApiClient()))..add(LoadProducts()),
            child: const ProductListPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.productEdit,
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return ProductFormPage(productId: id);
          },
        ),
        // ... route อื่น ๆ
      ],
    ),
  ],
);
```

เปลี่ยนหน้า:

```dart
context.go(AppRoutes.products); // ไปหน้าเมนูหลัก
context.push(AppRoutes.productEditPath(product.id)); // เปิดหน้าย่อย (กดกลับได้)
context.pop(); // ย้อนกลับ
```

### แอนิเมชันเปลี่ยนหน้า (ซูม ไม่ใช่เลื่อน)

ทุก route ใช้ `pageBuilder` + `AppPageTransition` (`core/routes/app_page_transition.dart`) — ห้ามใช้ `builder:` ตรง ๆ

| ใช้กับ | เข้ามา | ตอนถูกหน้าอื่นแทน |
|---|---|---|
| `AppPageTransition.forward` — หน้าทั่วไป | ขยายจาก 0.9 → 1 + จางเข้า (เด้งนิด ๆ ตอนจบ) = เดินหน้า | หด 1 → 0.9 + จางหาย = ถอยไปข้างหลัง |
| `AppPageTransition.backward` — หน้า login (มาจากการออกจากระบบ) | ย่อจาก 1.1 → 1 + จางเข้า = ถอยหลัง | ขยาย 1 → 1.1 + จางหาย = ผ่านไปข้างหน้า |

- login → หน้าแรก: หน้า login ขยายจางหาย หน้าแรกขยายเข้ามา (เดินหน้า)
- ออกจากระบบ: หน้าแรกหดจางหาย หน้า login ย่อเข้ามา (ถอยหลัง)
- `context.pop()` เล่นแอนิเมชันย้อนกลับของหน้านั้นเอง (หดออก) = ถอยหลัง
- ความเร็ว / ขนาดซูม แก้ที่ `AppPageTransition` ที่เดียว
- `app.dart` มี `ColoredBox(AppColors.background)` รองไว้ใต้ทุกหน้า ระหว่างจางจะได้ไม่เห็นพื้นดำ

### Login และ token (ทำแล้ว)

```
LoginPage ──LoginSubmitted──▶ AuthBloc ──▶ AuthRepository.login ──▶ ApiClient.post('/auth/login')
                                                │
                                                ├─ ใส่ token ใน ApiClient.token (ทุก request แนบ Authorization: Bearer <token> ให้เอง)
                                                └─ ติ๊ก "จดจำ" → เก็บ token ใน shared_preferences ด้วย
```

| เรื่อง | ทำยังไง |
|---|---|
| เปิดแอป | `main()` เรียก `AuthRepository(ApiClient()).loadSavedToken()` → มี token ที่จดจำไว้ก็เข้าหน้าแรกได้เลย |
| กันเข้าหน้าที่ต้อง login | `redirect` ใน `appRouter`: ไม่มี token → ไป `/login`, มี token แล้วเปิด `/login` → ไป `/` |
| login สำเร็จ | `AuthState.status == success` → `LoginPage` ไป `AppRoutes.dashboard` และเก็บอีเมลล่าสุด (`last_email`) ในเครื่องเสมอ |
| เปิดหน้า login | `initState` ส่ง `SavedEmailRequested` → `AuthState.savedEmail` → ใส่ช่องอีเมลให้ (ถ้ายังว่าง) |
| login ไม่ผ่าน | แสดง `'error.${state.errorCode}'.tr` เหนือปุ่ม |
| ไม่ติ๊กจดจำ | token อยู่แค่ในหน่วยความจำ → กด refresh / ปิดเว็บ ต้อง login ใหม่ |
| logout | `LogoutRequested` → ลบ token ทั้ง 2 ที่ (อีเมลล่าสุดยังอยู่) → กลับ `/login` |

error code ที่ `ApiClient` โยนออกมาเป็น `ApiException(code)`:
- code จาก API ตรง ๆ เช่น `invalid_credentials`
- `network_error` = ต่อ server ไม่ได้ (API ไม่ได้เปิด / เน็ตหลุด / CORS ไม่ผ่าน)
- `server_error` = API ตอบ error แต่ไม่มี `{"error": ...}`
- bloc เจอ error อื่นที่ไม่ใช่ `ApiException` → `unknown_error`

token หมดอายุ (7 วัน) / ถูกปฏิเสธ: API ตอบ 401 `unauthorized` → `ApiClient` เรียก `ApiClient.onUnauthorized` (ตั้งใน `main.dart`) → ลบ token แล้ว `appRouter.go(AppRoutes.login)`
(login ไม่ผ่าน `invalid_credentials` ก็เป็น 401 แต่ไม่เรียก `onUnauthorized`)

### หน้า + bloc ของแต่ละเมนู (ทำแล้ว)

ทุกหน้าสร้าง bloc ใน `app_router.dart` แล้ว `..add(<Event โหลดข้อมูล>)` ทันที — ออกจากหน้าแล้วกลับมา = bloc ใหม่ โหลดข้อมูลใหม่

| เมนู | Route | Bloc | หมายเหตุ |
|---|---|---|---|
| ภาพรวม | `/` | `DashboardBloc` | เลือกเดือนได้ (`MonthSwitcher`) |
| สินค้า | `/products` | `ProductBloc` | ค้นหาในเครื่อง (`visibleProducts`), ลบสินค้าที่อยู่ในใบกำกับไม่ได้ |
| คำนวณต้นทุน | `/cost` | `CostBloc` | แก้ใบต้นทุนในเครื่องก่อน (`isDirty`) แล้วกด "บันทึก" ส่งทั้งใบ |
| สต็อก | `/stock` | `StockBloc` | โหลดคงเหลือทุกสินค้าครั้งเดียว กรอง "ใกล้หมด" ในเครื่อง, แท็บประวัติโหลดเมื่อเปิด |
| รายรับ-รายจ่าย | `/transactions` | `TransactionBloc` | หมวดเป็นรหัส (`TransactionModel.incomeCategories / expenseCategories`) แสดงด้วย `'transaction.category.<code>'.tr` |
| ใบกำกับภาษี | `/invoices`, `/invoices/create`, `/invoices/:id` | `InvoiceListBloc`, `InvoiceFormBloc`, `InvoiceDetailBloc` | ออกใบสำเร็จ → ไปหน้าดูใบ (`AppRoutes.invoiceDetailPath(id)`) |
| ตั้งค่า | `/settings` | `SettingsBloc` + `LanguageBloc` | ต้องกรอกเลขผู้เสียภาษีก่อนออกใบกำกับ |

ผลของการบันทึก / ลบ แยกเป็น field ของ state: `saveStatus` / `saveErrorCode` (กล่องฟอร์มใช้ — สำเร็จแล้วปิดเอง ไม่สำเร็จแสดง error ในกล่อง) และ `deleteStatus` / `deleteErrorCode` (หน้าใช้ — แสดง snackbar)
กล่องฟอร์มเปิดด้วย `XxxDialog.show(context, ...)` ซึ่งส่ง bloc ของหน้าเข้าไปด้วย `BlocProvider.value`

ลองหน้าจอกับ API อื่นที่ไม่ใช่ `http://localhost:8080/api/v1` (เช่น server จริง / API ทดสอบ):
`flutter build web --dart-define=API_URL=https://api.example.com/api/v1` (favicon ใน `web/index.html` ต้องแก้เอง)

---

## 8. Widget แบบ Atomic Design

| ระดับ | คืออะไร | import ได้จาก | ตัวอย่าง |
|---|---|---|---|
| **atoms** | ชิ้นเล็กสุด ใช้ซ้ำทุกที่ | Flutter เท่านั้น | `AppButton`, `AppTextField`, `AppDropdown`, `AppLoading`, `AppBadge`, `MoneyText` |
| **molecules** | atoms หลายตัวรวมกัน | atoms | `SearchField`, `StatCard`, `AmountRow`, `EmptyView`, `ErrorView` |
| **organisms** | ส่วนใหญ่ของหน้า | atoms, molecules | `PageLayout`, `AppSideMenu`, `AppTopBar`, `AppDataTable`, `FormCard`, `ScreenScaler` |
| **pages** | หน้าจอจริง (อยู่ใน feature) | ทุกระดับ + bloc | `ProductListPage` |

กฎของ widget กลาง (`shared/widgets`):

1. ชื่อขึ้นต้นด้วย `App` ถ้าเป็นตัวแทน widget ของ Flutter (เช่น `AppButton` แทน `ElevatedButton`)
2. **ไม่รู้จัก bloc** — รับข้อมูลผ่าน constructor และส่งเหตุการณ์ออกผ่าน callback (`onPressed`, `onChanged`)
3. สี / ขนาด ใช้จาก `AppColors`, `AppSizes` ห้าม hardcode — ตัวอักษรใช้ `Theme.of(context).textTheme.xxx` ห้ามใส่ `fontSize` / `fontFamily` เอง
4. ข้อความรับเข้ามาจากข้างนอก (คนเรียกใช้ใส่ `.tr` เอง)
5. หน้าจอต้องใช้ widget กลางก่อนเสมอ ถ้าไม่มี → สร้างเพิ่มใน shared ถ้าใช้ ≥ 2 feature
6. `PageLayout`: จอ `mobile` / `tablet` ให้เมนูข้างเป็น Drawer (ปุ่ม ☰), จอ `desktop` แสดงเมนูข้างกว้าง `AppSizes.sideMenuWidth` และมีปุ่ม ☰ หด / กางเมนูแบบ animation (`PageLayout.menuAnimationDuration`) — หดแล้วเหลือแถบไอคอน `AppSizes.sideMenuCollapsedWidth` (ชี้แล้วเห็นชื่อเมนู) — `AppSideMenu` เลือกแบบไอคอนอย่างเดียวเองเมื่อกว้างไม่ถึง `AppSizes.sideMenuCompactBreak` (ดูหัวข้อ "รองรับทุกขนาดจอ" ด้านล่าง)
7. เมนูทั้งหมดอยู่ใน `AppMenu.items` (`core/routes/app_menu.dart`) — เพิ่มหน้าใหม่ในเมนู = เพิ่ม `AppMenuItem` 1 บรรทัด + route ใน `ShellRoute`
8. หน้าที่ยังไม่ได้ทำใช้ `ComingSoonView` (molecules) บอกว่าหน้านั้นจะทำอะไร

```dart
// lib/shared/widgets/atoms/app_button.dart
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: _label(),
    );
  }

  Widget _label() {
    if (!isLoading) return Text(text);
    return const SizedBox.square(
      dimension: AppSizes.loadingSize,
      child: CircularProgressIndicator(strokeWidth: AppSizes.loadingStroke),
    );
  }
}
```

หน้าจอ (page) อ่าน state จาก bloc แล้วเลือก widget ที่จะแสดง:

```dart
// lib/features/product/pages/product_list_page.dart
class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.status == AppStatus.loading) {
          return const AppLoading();
        }
        if (state.status == AppStatus.failure) {
          return ErrorView(message: state.errorMessage);
        }
        if (state.products.isEmpty) {
          return EmptyView(message: 'product.empty'.tr);
        }
        return ProductTable(products: state.products); // อยู่ใน features/product/widgets
      },
    );
  }
}
```

หน้าที่โค้ดเยอะ (`build()` ยาวเกินประมาณ 60 บรรทัด หรือไฟล์ยาวเกินประมาณ 150 บรรทัด) → แยกส่วนย่อยเป็น extension ในไฟล์ `<ชื่อหน้า>_ext.dart` (เชื่อมกันด้วย `part` / `part of`) ให้ `build()` เหลือแค่โครงหน้า — กฎและตัวอย่างอยู่ใน skill `simple-code` หัวข้อ "แยกโค้ดหน้าเป็น extension"

### รองรับทุกขนาดจอ (Responsive)

แอปใช้แบบ cross platform ต้องใช้ได้ตั้งแต่มือถือจนถึงจอใหญ่ แบ่งเป็น 2 วิธี:

1. **จอเล็กถึงจอคอมทั่วไป (≤ 1440)** — จัด layout ใหม่ตามประเภทจอ
2. **จอใหญ่ (> 1440)** — ไม่จัด layout ใหม่ แต่**ขยายทั้งแอปตามสัดส่วนเหมือนขยายรูปภาพ** หน้าตาเหมือนจอ 1440 ทุกอย่าง แค่ใหญ่ขึ้น

| ความกว้างจอ | `ScreenType` | layout |
|---|---|---|
| < 600 | `mobile` | 1 คอลัมน์, เมนูเป็น Drawer, ตาราง → รายการแบบการ์ด |
| 600 – 1023 | `tablet` | 1–2 คอลัมน์, เมนูเป็น Drawer |
| 1024 – 1440 | `desktop` | เมนูข้างแสดงตลอด, หลายคอลัมน์ |
| > 1440 | `desktop` | เหมือน 1440 แล้ว `ScreenScaler` ขยายทั้งแอป (สูงสุด 2 เท่า) |

| ไฟล์ | หน้าที่ |
|---|---|
| `core/constants/screen_type.dart` | `enum ScreenType { mobile, tablet, desktop }` |
| `core/utils/responsive_util.dart` | ตัวเลขทั้งหมด (`tabletMinWidth`, `desktopMinWidth`, `designWidth`, `maxScale`) + `typeOf(width)`, `scaleOf(width)` — แก้ตัวเลขที่นี่ที่เดียว |
| `core/helpers/responsive_helper.dart` | `ResponsiveHelper.screenType(context)` ใช้ในหน้าเพื่อเลือก layout |
| `shared/widgets/organisms/screen_scaler.dart` | ขยายทั้งแอปบนจอใหญ่ ใส่ใน `builder` ของ `MaterialApp` ครั้งเดียว |

`ScreenScaler` ทำงานยังไง: จอกว้าง 2160 → `scale = 2160 ÷ 1440 = 1.5` → บอกแอปผ่าน `MediaQuery` ว่าจอกว้าง 1440
แล้วใช้ `FittedBox` ขยายภาพทั้งแอปขึ้น 1.5 เท่าให้เต็มจอ ตัวอักษร ปุ่ม ระยะห่าง ใหญ่ขึ้นเท่ากันหมด และยังกดได้ปกติ
ตัวอักษรยังคมชัด เพราะ Flutter วาดใหม่ที่ขนาดจริง ไม่ได้ยืดภาพ pixel ส่วนรูปภาพจะเลือกไฟล์ความละเอียดสูง (2x, 3x) ให้เอง ถ้ามีใน `assets/images/`

```dart
// เลือก layout ในหน้า — ใช้ if ธรรมดา
if (ResponsiveHelper.screenType(context) == ScreenType.mobile) {
  return ProductCardList(products: products);
}
return ProductTable(products: products);
```

กฎ:
- ห้ามพิมพ์ตัวเลข breakpoint เอง → ใช้ `ResponsiveHelper.screenType(context)`
- ห้ามคูณขนาดด้วย scale เอง และไม่ใช้ package แบบ screenutil — `ScreenScaler` จัดการให้ทั้งแอปแล้ว
- ใช้ `Expanded` / `Flexible` / `Wrap` แทนความกว้างตายตัว ส่วนที่อาจยาวเกินจอใส่ใน `ListView` / `SingleChildScrollView`
- ลองทุกหน้าที่ความกว้าง 375, 768, 1280, 1920, 2560

---

## 9. Utils และ Helpers

| | Utils (`core/utils`) | Helpers (`core/helpers`) |
|---|---|---|
| คืออะไร | ฟังก์ชันคำนวณ / แปลงค่า | ฟังก์ชันช่วยงาน UI / plugin |
| ใช้ BuildContext | ไม่ใช้ | ใช้ได้ |
| เขียน test | **บังคับ** | ไม่บังคับ |
| ตัวอย่าง | `MoneyUtil`, `TaxUtil`, `CostUtil`, `DateUtil`, `ValidatorUtil` | `DialogHelper`, `SnackbarHelper`, `PdfHelper` |

เขียนเป็น `class` ที่มีแต่ `static` function

โค้ดที่ใช้ตั้งแต่ **2 จุดขึ้นไป** ต้องแยกเป็นฟังก์ชันกลาง ห้าม copy-paste — ถ้าใช้ซ้ำแค่ในไฟล์เดียวให้เป็น private function (`_ชื่อ`) ในไฟล์นั้น ถ้าใช้หลายไฟล์ให้ย้ายมาไว้ที่ utils / helpers

```dart
// lib/core/utils/money_util.dart
class MoneyUtil {
  /// ปัดเศษ 2 ตำแหน่ง เช่น 10.456 -> 10.46
  static double round2(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  /// 1234.5 -> "1,234.50"
  static String format(double value) {
    return NumberFormat('#,##0.00').format(value);
  }
}
```

```dart
// lib/core/utils/tax_util.dart
class TaxUtil {
  static const double vatPercent = 7;

  /// VAT จากราคาก่อน VAT เช่น 100 -> 7
  static double vat(double priceBeforeVat) {
    return MoneyUtil.round2(priceBeforeVat * vatPercent / 100);
  }

  /// ราคารวม VAT เช่น 100 -> 107
  static double totalWithVat(double priceBeforeVat) {
    return MoneyUtil.round2(priceBeforeVat + vat(priceBeforeVat));
  }

  /// ถอด VAT ออกจากราคารวม เช่น 107 -> 100
  static double priceBeforeVat(double totalWithVat) {
    return MoneyUtil.round2(totalWithVat * 100 / (100 + vatPercent));
  }
}
```

```dart
// lib/core/utils/cost_util.dart
class CostUtil {
  /// ต้นทุนต่อหน่วย = (วัตถุดิบ + ค่าแรง + ค่าใช้จ่ายอื่น) ÷ จำนวนที่ผลิตได้
  static double costPerUnit({
    required double material,
    required double labor,
    required double overhead,
    required int quantity,
  }) {
    if (quantity <= 0) return 0;
    return MoneyUtil.round2((material + labor + overhead) / quantity);
  }

  /// ราคาขาย = ต้นทุน × (1 + markup% ÷ 100)
  static double sellPrice({required double cost, required double markupPercent}) {
    return MoneyUtil.round2(cost * (1 + markupPercent / 100));
  }
}
```

```dart
// lib/core/utils/date_util.dart
class DateUtil {
  /// วันที่แบบไทย พ.ศ. เช่น 31/10/2569
  static String toThaiDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year + 543}';
  }
}
```

```dart
// lib/core/helpers/dialog_helper.dart
class DialogHelper {
  /// ถามยืนยัน คืนค่า true ถ้ากดยืนยัน
  static Future<bool> confirm(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('common.cancel'.tr)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('common.confirm'.tr)),
        ],
      ),
    );
    return result ?? false;
  }
}
```

---

## 10. ภาษา (JSON + `.tr`)

ไฟล์ภาษาเป็น JSON แบบ **แบน (flat)** ชื่อ key = `<feature>.<ชื่อ>` และข้อความกลางใช้ `common.`

```json
// assets/lang/th.json
{
  "common.save": "บันทึก",
  "common.cancel": "ยกเลิก",
  "common.confirm": "ยืนยัน",
  "common.search": "ค้นหา",
  "menu.dashboard": "ภาพรวม",
  "menu.products": "สินค้า",
  "menu.cost": "คำนวณต้นทุน",
  "menu.stock": "สต็อก",
  "menu.transactions": "รายรับ-รายจ่าย",
  "menu.invoices": "ใบกำกับภาษี",
  "menu.settings": "ตั้งค่า",
  "product.title": "รายการสินค้า",
  "product.empty": "ยังไม่มีสินค้า",
  "stock.low": "เหลือ {count} ชิ้น"
}
```

`en.json` ต้องมี key **ครบเหมือน** `th.json` (มี unit test เช็ค)

ลงทะเบียนไฟล์ใน `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/lang/
```

```dart
// lib/core/lang/app_lang.dart
import 'dart:convert';

import 'package:flutter/services.dart';

class AppLang {
  static String currentCode = 'th';
  static Map<String, dynamic> _texts = {};

  /// โหลดไฟล์ภาษา เช่น AppLang.load('th')
  static Future<void> load(String code) async {
    final jsonText = await rootBundle.loadString('assets/lang/$code.json');
    _texts = jsonDecode(jsonText) as Map<String, dynamic>;
    currentCode = code;
  }

  /// ถ้าหาไม่เจอ คืน key กลับไป (จะได้เห็นว่าลืมใส่ key ไหน)
  static String text(String key) {
    return _texts[key]?.toString() ?? key;
  }
}

extension TrExtension on String {
  /// 'common.save'.tr -> "บันทึก"
  String get tr => AppLang.text(this);

  /// 'stock.low'.trParams({'count': '5'}) -> "เหลือ 5 ชิ้น"
  String trParams(Map<String, String> params) {
    var result = tr;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
```

```dart
// lib/core/lang/language_bloc.dart — state เป็นแค่รหัสภาษา (String)
class ChangeLanguage {
  ChangeLanguage(this.code);
  final String code;
}

class LanguageBloc extends Bloc<ChangeLanguage, String> {
  LanguageBloc() : super(AppLang.currentCode) {
    on<ChangeLanguage>((event, emit) async {
      await AppLang.load(event.code);
      emit(event.code);
    });
  }
}
```

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLang.load('th');
  runApp(const App());
}
```

```dart
// lib/app.dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LanguageBloc(),
      child: BlocBuilder<LanguageBloc, String>(
        builder: (context, langCode) {
          return MaterialApp.router(
            key: ValueKey(langCode), // เปลี่ยนภาษา -> สร้างหน้าใหม่ ข้อความ .tr อัปเดตทั้งแอป
            title: 'CostBook',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            builder: (context, child) => ScreenScaler(child: child ?? const SizedBox()), // จอใหญ่ → ขยายทั้งแอป
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
```

ใช้งาน:

```dart
Text('product.title'.tr)
Text('stock.low'.trParams({'count': '${product.stock}'}))
context.read<LanguageBloc>().add(ChangeLanguage('en')); // เปลี่ยนภาษา
```

error จาก API มาเป็น code เช่น `{"error": "product_name_required"}` → แสดงด้วย `'error.$code'.tr`
(เพิ่ม key `"error.product_name_required"` ทั้งใน `th.json` และ `en.json`)

---

## 11. สูตรคำนวณ และใบกำกับภาษี

| เรื่อง | สูตร |
|---|---|
| ต้นทุนรวม | วัตถุดิบ + ค่าแรง + ค่าใช้จ่ายอื่น |
| ต้นทุนต่อหน่วย | ต้นทุนรวม ÷ จำนวนที่ผลิตได้ |
| ราคาขาย | ต้นทุนต่อหน่วย × (1 + markup% ÷ 100) |
| กำไรต่อหน่วย | ราคาขาย − ต้นทุนต่อหน่วย |
| VAT | ราคาก่อน VAT × 7 ÷ 100 |
| ถอด VAT จากราคารวม | ราคารวม × 100 ÷ 107 |
| stock คงเหลือ | รับเข้า − เบิกออก |
| ใกล้หมด | คงเหลือ ≤ จำนวนขั้นต่ำ (minStock) |

- เงินปัดเศษ 2 ตำแหน่งด้วย `MoneyUtil.round2` ทุกครั้งที่คำนวณเสร็จ
- สูตรทุกตัวอยู่ใน `core/utils` และต้องมี unit test

**ใบกำกับภาษีเต็มรูป** (ประมวลรัษฎากร ม.86/4) ต้องมี:

1. คำว่า "ใบกำกับภาษี" เห็นชัด
2. ชื่อ ที่อยู่ เลขประจำตัวผู้เสียภาษีของผู้ขาย + สำนักงานใหญ่ / สาขา
3. ชื่อ ที่อยู่ เลขประจำตัวผู้เสียภาษีของผู้ซื้อ + สำนักงานใหญ่ / สาขา
4. เลขที่ใบกำกับภาษี (และเล่มที่ ถ้ามี)
5. ชื่อ ชนิด ปริมาณ และมูลค่าของสินค้า
6. จำนวน VAT แยกจากมูลค่าสินค้าชัดเจน
7. วัน เดือน ปี ที่ออก

หมายเหตุ:
- เลขที่ใบกำกับควรให้ API รันให้ (กันเลขซ้ำ)
- **PDF ใช้วิธีถ่ายรูปกระดาษใบกำกับ** (`PdfHelper`): `InvoicePaper` (กว้าง 794 = A4) อยู่ใน `RepaintBoundary` → `toImage` ความละเอียด 3 เท่า → ใส่ใน PDF ขนาด A4 → `Printing.layoutPdf` (พิมพ์) / `Printing.sharePdf` (ดาวน์โหลด)
  - เหตุผล: ลองสร้างข้อความไทยด้วย package `pdf` + ฟอนต์ LINESeedSansTH แล้ววรรณยุกต์ที่ซ้อนสระบนหาย ("ที่อยู่" → "ทีอยู่") — Flutter วาดไทยถูก จึงถ่ายรูปจากหน้าจอแทน
  - ข้อเสีย: เลือก / copy ตัวหนังสือใน PDF ไม่ได้, ใบที่สินค้าเยอะจนยาวเกิน 1 หน้า A4 จะถูกย่อให้อยู่หน้าเดียว (ยังไม่แบ่งหลายหน้า)
- ให้นักบัญชีตรวจรูปแบบใบกำกับอีกครั้งก่อนใช้งานจริง
- e-Tax Invoice ยังไม่อยู่ในขอบเขตตอนนี้

---

## 12. Unit Test

- `test/` วางโครงเหมือน `lib/` เช่น `lib/core/utils/tax_util.dart` → `test/core/utils/tax_util_test.dart`
- บังคับมี test: **utils, models, blocs, ไฟล์ภาษา**
- วิธีรันและตรวจ: ดู `.claude/skills/unit-test-check/SKILL.md`

---

## 13. การตั้งชื่อ

| ชนิด | ชื่อไฟล์ | ชื่อ class |
|---|---|---|
| Page | `product_list_page.dart` | `ProductListPage` |
| Extension ของหน้า | `product_list_page_ext.dart` | `_ProductListPageExt` |
| Bloc | `product_bloc.dart` | `ProductBloc` |
| Event | `product_event.dart` | `LoadProducts`, `AddProduct`, `DeleteProduct` |
| State | `product_state.dart` | `ProductState` |
| Model | `product_model.dart` | `ProductModel` |
| Repository | `product_repository.dart` | `ProductRepository` |
| Widget กลาง | `app_button.dart` | `AppButton` |
| Widget ของ feature | `product_table.dart` | `ProductTable` |
| Util | `money_util.dart` | `MoneyUtil` |
| Helper | `dialog_helper.dart` | `DialogHelper` |
| Test | `money_util_test.dart` | — |

- ชื่อไฟล์ `snake_case`, ชื่อ class `PascalCase`, ตัวแปร `camelCase`
- import แบบ `package:costbook/...` เสมอ (ไม่ใช้ `../../`)
- 1 ไฟล์ = 1 class หลัก

---

## 14. คำสั่งที่ใช้บ่อย

```bash
flutter run -d chrome      # รันบน Chrome
flutter analyze            # ตรวจโค้ด
flutter test               # รัน unit test ทั้งหมด
flutter build web          # build ไว้ deploy (ได้ไฟล์ใน build/web)
```
