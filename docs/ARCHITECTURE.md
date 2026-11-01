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
| product | สินค้า + คงเหลือ + รับเข้า / เบิกออก (รวมกับสต็อกแล้ว) ในเมนูกลุ่ม "สินค้าและสต็อก" | `/products` |
| category | หมวดหมู่สินค้า (เพิ่ม / เปลี่ยนชื่อ / ลบ) | `/products/categories` |
| cost | คำนวณต้นทุนต่อหน่วย และราคาขายจาก % markup | `/cost` |
| stock | ประวัติสต็อก (รับเข้า / เบิกออก / ขาย) + กล่องรับเข้า / เบิกออกที่หน้าสินค้าใช้ร่วม | `/stock` |
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
| `fl_chart` | กราฟในหน้าภาพรวม (แท่งรายวัน, เส้นย้อนหลัง 6 เดือน) — ผู้ใช้อนุญาต 2026-10-31 |
| `image_picker` | เลือกรูปสินค้าจากเครื่อง + ย่อรูปบนเว็บให้ (ใช้ผ่าน `ImagePickHelper` เท่านั้น) — ผู้ใช้อนุญาต 2026-11-01 |
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
│   │   ├── constants/     app_status.dart, screen_type.dart, user_role.dart (owner / manager / staff), api_constants.dart (baseUrl, companyLogoUrl, productImageUrl, userAvatarUrl)
│   │   ├── lang/          app_lang.dart (.tr), language_bloc.dart (เปลี่ยน + จำภาษา)
│   │   ├── network/       api_client.dart (get / post / put / delete + token + 401 + เก็บผล GET ไว้ใน cache), api_exception.dart (error code จาก API)
│   │   ├── routes/        app_routes.dart (ชื่อ route), app_router.dart (GoRouter + สร้าง bloc ของแต่ละหน้า), app_menu.dart, app_shell.dart, app_page_transition.dart
│   │   ├── theme/         app_colors.dart (สี), app_sizes.dart (ขนาดตัวอักษร / ระยะห่าง), app_theme.dart (ฟอนต์ + รวมเป็น ThemeData)
│   │   ├── utils/         money_util, tax_util, cost_util, date_util, validator_util, error_util, responsive_util,
│   │   │                  percent_util (% เทียบเดือนก่อน), market_util (เทียบราคาตลาด), chart_util (สเกลแกนกราฟ), name_util (ตัวอักษรย่อในรูปโปรไฟล์)
│   │   └── helpers/       dialog_helper.dart (ถามยืนยัน), snackbar_helper.dart, pdf_helper.dart (พิมพ์ / ดาวน์โหลด PDF), responsive_helper.dart,
│   │                      image_pick_helper.dart (เลือกรูป + ย่อเหลือด้านยาว 1200 px)
│   ├── shared/
│   │   └── widgets/
│   │       ├── atoms/       app_button, app_text_field, app_dropdown, app_loading, app_badge, money_text, shop_logo, app_image_box (รูปมุมมน / ไม่มีรูป = กล่องไอคอน)
│   │       ├── molecules/   empty_view, error_view, stat_card (การ์ดตัวเลขสรุป ใช้ทั้งภาพรวม / รายรับ-รายจ่าย / ราคาตลาด), month_switcher, search_field, section_card, notice_banner,
│   │       │                chart_legend, ranked_bar_list (แท่งแนวนอนเรียงมากไปน้อย), market_range_bar (ราคาเรา vs ช่วงราคาตลาด)
│   │       └── organisms/   page_layout, app_side_menu, screen_scaler, page_content (ขอบ + ความกว้างหน้า + เว้นที่ล่างให้ปุ่มแชท), page_toolbar,
│   │                        app_data_table (จอคอม = ตาราง / มือถือ = การ์ด / แคบกว่า minWidth รวม = เลื่อนซ้าย-ขวา), app_dialog (โครง dialog กลาง + แท็บใต้หัวได้), form_dialog (กล่องฟอร์ม),
│   │                        app_alert_dialog (กล่องยืนยัน / แจ้งผล ไอคอนวงกลม), stat_grid
│   └── features/          ทุก feature: models → repository → bloc → pages (+ _ext ถ้ายาว) → widgets
│       ├── auth/            login + จดจำ token / อีเมล
│       ├── dashboard/       หน้าภาพรวม (pages: dashboard_page + _ext + _charts)
│       │                    widgets: dashboard_panel (กล่อง), sales_trend_chart, weekday_chart, monthly_trend_chart,
│       │                    category_split, top_products_table, margin_gauge, ai_ask_card (พิมพ์ถาม → เปิดหน้าต่างแชท)
│       ├── market/          เช็คราคาตลาดด้วย AI ของสินค้า 1 ตัว (หน้า /products/:id/market)
│       ├── assistant/       แชทผู้ช่วย AI แบบลอยทุกหน้า (AiRepository + AiStatusModel ใช้ร่วมกับ market / settings) ไม่มีหน้าของตัวเอง
│       │                    widgets/chat_launcher (ปุ่มมุมขวาล่าง / หน้าต่าง), chat_panel (+ _ext), chat_bubble, ai_action_card
│       ├── sell/            หน้าขายด่วน (ใช้ InvoiceFormBloc ของ invoice) + widgets: sell_product_tile (การ์ดสินค้า + เลขจำนวนในบิล), sell_bill_panel (บิล),
│       │                    sell_cart_row (แถวในบิล − / +), sell_item_dialog (แก้จำนวน / ราคา), payment_dialog (รับเงิน + เงินทอน)
│       ├── product/         รายการ / ค้นหา / หมวด / เพิ่ม / แก้ / ลบสินค้า + รูป (widgets/product_form_dialog.dart, custom_field_input.dart, product_image.dart)
│       ├── cost/            ใบต้นทุนของสินค้า + markup → ราคาขาย (widgets/cost_item_dialog.dart = ฟอร์มบรรทัดต้นทุน / รายการที่ใช้บ่อย (`forPreset`), cost_presets_dialog.dart = จัดการรายการที่ใช้บ่อย)
│       ├── stock/           ประวัติสต็อก + กล่องรับเข้า / เบิกออก แบบแท็บในหน้าต่างเดียว (widgets/stock_movement_dialog.dart ใช้ในหน้าสินค้าด้วย)
│       ├── category/        หมวดหมู่สินค้า (CategoryBloc + หน้า /products/categories + widgets/category_form_dialog.dart)
│       ├── transaction/     รายรับ-รายจ่ายรายเดือน + สรุป (widgets/transaction_form_dialog.dart)
│       ├── invoice/         bloc 3 ตัว: invoice_list / invoice_form / invoice_detail
│       │                    pages: invoice_list_page, invoice_form_page (+ _ext), invoice_detail_page
│       │                    widgets: invoice_item_row.dart (บรรทัดสินค้าในฟอร์ม), invoice_paper.dart (กระดาษใบกำกับ A4)
│       ├── user/            ผู้ใช้ที่ login อยู่ + โปรไฟล์ + จัดการผู้ใช้ (เจ้าของร้าน): ProfileBloc (shell), UserListBloc
│       │                    pages: profile_page, user_list_page (+ _ext)
│       │                    widgets: user_avatar (รูป / ตัวอักษรย่อ), role_badge, profile_photo_card, profile_info_section, password_section,
│       │                    user_form_dialog (เพิ่ม / แก้ผู้ใช้), reset_password_dialog
│       └── settings/        ข้อมูลร้าน + รูปแบบร้าน + ช่องข้อมูลเพิ่มเติม (widgets/product_field_dialog.dart) + key AI (widgets/ai_key_section.dart) + โลโก้ + เปลี่ยนภาษา
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

### เก็บข้อมูลไว้ (cache) — เปลี่ยนหน้าไปมาไม่ต้องรอโหลด ไม่ยิง API ซ้ำ

ทำ 2 ชั้น (ผู้ใช้ขอ 2026-11-01 "เปลี่ยนหน้าแล้วยิง API ทุกครั้ง เปลืองไหม / มีของใหม่ค่อยขึ้นมาเนียน ๆ"):

1. **`ApiClient` เก็บผล GET** ไว้ในหน่วยความจำ (key = path เช่น `/dashboard?month=2026-11`, refresh หน้าเว็บ = หาย)
   - เพิ่งโหลดไม่เกิน `ApiClient.cacheFreshFor` (30 วินาที) และหลังจากนั้นยังไม่มีการแก้ข้อมูล → `get` คืนของเดิมเลย **ไม่ยิง API**
   - แก้ข้อมูลสำเร็จ (POST / PUT / DELETE / อัปโหลดไฟล์) → ของที่เก็บไว้ถือว่า**เก่าทั้งหมด** (ขาย 1 บิล → สต็อก / ภาพรวม / รายรับเปลี่ยนตาม) ครั้งหน้ายิงใหม่
   - `api.cached(path)` = ของที่เคยโหลด (เก่าแค่ไหนก็ได้) ไว้โชว์ก่อน / `ApiClient.clearCache()` ตอน login / logout / ได้ 401 → คนต่อไปไม่เห็นข้อมูลของคนก่อน
2. **bloc ของหน้าหลักโชว์ของเดิมก่อน** (`_showCachedFirst`): เคยโหลดแล้ว → emit success ด้วยของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วค่อยโหลดใหม่ ข้อมูลใหม่มาก็ emit ทับเงียบ ๆ (เหมือนเดิม = Equatable ไม่ rebuild) / ยังไม่เคยโหลด → หน้าโหลดตามปกติ
   - โหลดใหม่ไม่สำเร็จแต่มีของเดิมโชว์อยู่ (status success) → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error
   - repository มีคู่ `getXxx()` (ยิง API / ได้จาก cache ถ้ายังใหม่) กับ `cachedXxx()` (ของเดิม หรือ null)
   - ทำแล้ว: ภาพรวม (ต่อเดือน), ขายสินค้า + ออกเอกสาร (`InvoiceFormBloc`), รายการสินค้า + หมวด, สต็อก, หมวดหมู่, คำนวณต้นทุน (ใบต้นทุน — กำลังแก้ใบอยู่ ของใหม่ไม่ทับ), รายรับ-รายจ่าย (ต่อเดือน), เอกสารขาย (ต่อเดือน), จัดการผู้ใช้
   - ไม่ได้ทำ (เปิดไม่บ่อย ได้ชั้นที่ 1 อยู่แล้ว): เช็คราคาตลาด, ดูเอกสารขาย 1 ใบ / bloc ที่อยู่ที่ shell (ตั้งค่า / โปรไฟล์ / AI) สร้างครั้งเดียว ไม่โหลดซ้ำตอนเปลี่ยนหน้าอยู่แล้ว
- API ตอบ `Access-Control-Max-Age: 600` → browser จำคำตอบของ OPTIONS (ถามสิทธิ์ CORS) 10 นาที ไม่ต้องถามก่อนทุก request

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
| ใช้ทั้งแอป (ภาษา) | `app.dart` |
| ใช้ทุกหน้าหลัง login (`AuthBloc`, `SettingsBloc` = ข้อมูลร้าน + รูปแบบร้าน + ช่องข้อมูลเพิ่มเติม, `AssistantBloc` = แชท AI, `ProfileBloc` = ผู้ใช้ที่ login อยู่ + role) | `ShellRoute` ใน `app_router.dart` — หน้าไหนอยากรู้รูปแบบร้านใช้ `context.watch<SettingsBloc>()` / แชทอยู่ที่ shell → เปลี่ยนหน้าแล้วกลับมา แชทยังอยู่ (หายเมื่อ refresh / logout) |
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

error code ที่ `ApiClient` โยนออกมาเป็น `ApiException(code, params:)`:
- code จาก API ตรง ๆ เช่น `invalid_credentials`
- `params` = field อื่นใน JSON error นอกจาก `error` (แปลงเป็นข้อความ) เช่น `material_not_enough` มี `material` / `unit` / `need` / `have` → bloc เก็บด้วย `ErrorUtil.paramsOf(error)` แล้วหน้าจอใช้ `'error.$code'.trParams(params)`
- `network_error` = ต่อ server ไม่ได้ (API ไม่ได้เปิด / เน็ตหลุด / CORS ไม่ผ่าน)
- `server_error` = API ตอบ error แต่ไม่มี `{"error": ...}`
- bloc เจอ error อื่นที่ไม่ใช่ `ApiException` → `unknown_error`

token หมดอายุ (7 วัน) / ถูกปฏิเสธ: API ตอบ 401 `unauthorized` → `ApiClient` เรียก `ApiClient.onUnauthorized` (ตั้งใน `main.dart`) → ลบ token แล้ว `appRouter.go(AppRoutes.login)`
(login ไม่ผ่าน `invalid_credentials` ก็เป็น 401 แต่ไม่เรียก `onUnauthorized`)

### หน้า + bloc ของแต่ละเมนู (ทำแล้ว)

ทุกหน้าสร้าง bloc ใน `app_router.dart` แล้ว `..add(<Event โหลดข้อมูล>)` ทันที — ออกจากหน้าแล้วกลับมา = bloc ใหม่ โหลดข้อมูลใหม่

| เมนู | Route | Bloc | หมายเหตุ |
|---|---|---|---|
| ภาพรวม | `/` | `DashboardBloc` | แถวบน `StatCard` 4 ใบแบบเดียวกับหน้ารายรับ-รายจ่าย (รายได้ / กำไรขั้นต้น / รายจ่าย / **กำไรสุทธิ = การ์ดผลลัพธ์พื้นเข้ม**, `badge: DeltaPill` เทียบเดือนก่อน, มือถือ 2 × 2 ด้วย `AppSizes.statCardMiniWidth`) → ยอดขาย (ตัวเลขใหญ่ + % เทียบเดือนก่อน — ไม่มีเดือนก่อนให้เทียบไม่แสดง, กราฟยอดสะสมเต็มความกว้าง มีจุดที่วันล่าสุด เห็นได้แม้มีข้อมูลวันเดียว, 3 หมวดแรก) คู่กับวันที่ขายดี → สินค้าขายดี คู่กับ margin (เกจ) → รายจ่ายตามหมวด คู่กับช่องถาม AI → ย้อนหลัง 6 เดือน (ตารางตัวเลขพับไว้ กดดูได้) → เทียบราคาตลาด คู่กับสต็อก — จอกว้าง ≥ 960 แถวละ 2 กล่อง (3 : 2) **สูงเท่ากันทั้งแถว** (`dashboardRowHeight` / `ListRowHeight` / `CompactRowHeight`; `DashboardPanel(scrollable:)` รายการยาวเลื่อนในกล่อง, `centered:` เนื้อหาอยู่กลาง, ไม่มีข้อมูล = ไอคอน + ข้อความกลางกล่อง) แคบกว่านั้นเรียงลงมาสูงตามเนื้อหา — ใช้ `IntrinsicHeight` ไม่ได้เพราะในกล่องมี `LayoutBuilder` |
| เช็คราคาตลาด | `/products/:id/market` | `MarketBloc` | เปิดจากปุ่มรูปลูกโลกในหน้าสินค้า หรือชื่อสินค้าในภาพรวม — ดูผลเดิมฟรี กด "เช็คใหม่" = ค่าใช้จ่าย AI |
| ขายสินค้า | `/sell` | `InvoiceFormBloc` (ตัวเดียวกับฟอร์มเอกสารขาย) | โหลดเฉพาะสินค้าที่ขาย (`forSale`) ซ่อนวัสดุ / หน้าขายหน้าร้าน (POS — ผู้ใช้เลือกแบบ "บิลติดขวา" 2026-11-01): **จอคอม / แท็บเล็ต** = สินค้าซ้าย (ช่องค้นหา / สแกน + ปุ่มกรองหมวด `productCategories` ติดด้านบน การ์ดเลื่อนได้ ไม่ใช้ `PageContent`) + บิลขวาสูงเต็มจอ (`SellBillPanel` กว้าง `sellBillWidth` / `sellBillCompactWidth`, ใต้บิลเว้น `chatLauncherSpace` ให้ปุ่มแชท AI) / **มือถือ** = สินค้าเต็มจอ + แถบล่างสูง `sellCartBarHeight` จำนวนชิ้น + ยอด + "ดูบิล / รับเงิน" (ปุ่มแชท AI ถูกยกขึ้นไปเหนือแถบ — `AppShell._chatBottom` ส่ง `ChatLauncher(bottom:)` / ท้ายรายการสินค้าเว้น `chatLauncherSpace` ให้เลื่อนพ้นปุ่มแชท) → บิลเลื่อนขึ้นมา (`showModalBottomSheet(useRootNavigator: true)` ทับปุ่มแชท) / บิล: หัว (จำนวนชิ้น + ล้างบิล ถามยืนยัน) → รายการเลื่อนได้ (`SellCartRow`: − / + / เหลือ 1 ชิ้น − = ถังขยะ, กดชื่อ = `SellItemDialog` แก้จำนวน / ราคา / เอาออก) → ท้ายบิลติดอยู่กับที่ (ชื่อลูกค้า — ร้านจด VAT ต้องใส่ ไม่ใส่ขึ้นเตือนที่ช่อง, ส่วนลด, ยอด, ปุ่มรับเงิน) / การ์ดสินค้าที่อยู่ในบิล = ขอบส้ม + เลขจำนวน (`quantityOf`) / สแกนรหัสแล้วกด Enter (`InvoiceCodeScanned`) — มือถือไม่ autofocus ช่องค้นหา (คีย์บอร์ดไม่เด้ง) / **รับเงิน** → `PaymentDialog` (ยอด, ช่องรับเงินมา — เว้นว่าง = พอดี, ปุ่มลัด `CashUtil.quickAmounts`, เงินทอน `CashUtil.change` / เงินไม่พอกดยืนยันไม่ได้ — เงินทอนไม่ได้บันทึก แค่ช่วยคิด) → ออกเอกสาร → "ขายแล้ว" บอกรับมา + ทอน → "ขายบิลต่อไป" (`InvoiceFormReset` ล้างบิล + โหลดสต็อกใหม่) |
| รายการสินค้า | `/products` (`?low=1` = กรองใกล้หมด) | `ProductBloc` + `StockBloc(withHistory: false)` | **สินค้ากับสต็อกอยู่หน้าเดียว**: ค้นหาในเครื่อง (`visibleProducts` ค้นจากชื่อ / รหัส / หมวด / ช่องเพิ่มเติม) + ปุ่มเลือกหมวด (`ProductState.categories` จาก API กรองด้วย `categoryId`) + "เฉพาะใกล้หมด (n)" + **แท็บแบบแฟ้มบนตาราง** ทั้งหมด / สินค้าขาย / วัสดุ พร้อมจำนวน (`AppTabs` ใน `AppDataTable(header:)`, `ProductState.kind` / `kindCount`, `ProductKindChanged`) — มีสินค้าแล้วตาราง + แท็บแสดงเสมอแม้กรองแล้วว่าง (ข้อความว่างอยู่ใต้ตาราง, แท็บวัสดุว่าง = บอกวิธีเพิ่มวัสดุ) — วัสดุมีป้าย "วัสดุ" (บรรทัดใต้ชื่อ คู่กับรหัส · หมวด · หน่วย) ราคาขายเป็น "—", column ของช่องเพิ่มเติมที่ `showInList`, **ท้ายแถวมี 2 ปุ่ม**: ⇅ รับเข้า / เบิกออก (เฉพาะสินค้าที่นับสต็อก เปิด `StockMovementDialog` เลือกสินค้าแถวนั้นไว้) + ⋮ เมนู (`PopupMenuButton`: เช็คราคาตลาด / แก้ไข / ลบ) — คอลัมน์ปุ่มกว้างตายตัว `tableActionsWidth` ชื่อสินค้าได้ที่กว้างขึ้น / คงเหลือ: จำนวนบรรทัดบน ป้ายใกล้หมดบรรทัดล่าง (ทุกแถวหน้าตาเหมือนกัน) / จอแคบจนตารางไม่พอ → เลื่อนซ้าย-ขวา (`minWidth` ของคอลัมน์) แทนการบีบให้ตกบรรทัด, ปุ่ม "รับเข้า / เบิกออก" แถบบนปุ่มเดียว (บันทึกแล้วโหลดสินค้าใหม่), ลบสินค้าที่อยู่ในใบกำกับไม่ได้, รูปเล็กหน้าชื่อ, ฟอร์มเลือกหมวดจากรายการ (`categoryId`, ไม่มีหมวด = '') + สวิตช์ "ขายสินค้านี้" (`forSale` ปิด = วัสดุ ใช้ในใบต้นทุนของสินค้าอื่น ขายไม่ได้) |
| หมวดหมู่สินค้า | `/products/categories` | `CategoryBloc` | เพิ่ม / เปลี่ยนชื่อ (สินค้าทุกตัวเปลี่ยนตาม) / ลบ (ถามยืนยัน บอกจำนวนสินค้าที่จะไม่มีหมวด) |

**รูปสินค้า** (1 รูป / สินค้า):

- `ProductModel.imageVersion` (จาก API, 0 = ไม่มีรูป) → `hasImage`, `imageUrl` = `/products/{id}/image?v=<imageVersion>` (เปลี่ยนรูปแล้ว URL เปลี่ยน รูปเก่าไม่ค้าง)
- แสดงด้วย `ProductImage` (ส่ง token ผ่าน `ApiClient.authHeaders` เพราะเส้นรูปต้อง login) — ตารางสินค้า / การ์ดมือถือ / การ์ดหน้าขายด่วน / ตัวอย่างในฟอร์ม
- ฟอร์มสินค้า: เลือกรูป (`ImagePickHelper.pick` ย่อด้านยาว ≤ 1200 px คุณภาพ 85%) → เกิน 1 MB เตือนทันทีไม่ส่ง → กดบันทึก = `ProductSaved(product, image:, removeImage:)`
- `ProductBloc`: บันทึกสินค้าก่อน แล้วอัปโหลด (`ApiClient.putFile`) / ลบรูป — รูปพังแต่สินค้าบันทึกแล้ว = ยังสำเร็จ (ปิดฟอร์ม กันกดซ้ำจนสินค้าซ้ำ) แล้วบอกผ่าน `imageErrorCode` → snackbar
- เพิ่ม plugin ใหม่แล้ว `flutter build web` ยังใช้ตัวลงทะเบียน plugin เก่า (เจอ "No implementation found") → ลบ `.dart_tool/flutter_build` หรือ `flutter clean` แล้ว build ใหม่
| คำนวณต้นทุน | `/cost` | `CostBloc` | แก้ใบต้นทุนในเครื่องก่อน (`isDirty`) แล้วกด "บันทึก" ส่งทั้งใบ, บรรทัดแบบ จำนวน × ราคา หรือ %, รายการที่ใช้บ่อย (`presets`): ปุ่ม "รายการที่ใช้บ่อย (n)" เปิดหน้าต่างเพิ่ม / แก้ / ลบ (ลบต้องยืนยัน, error อยู่ใน `presetErrorCode`) เปิดได้แม้ยังไม่มีสินค้า — แก้ราคาในรายการที่ใช้บ่อย **ไม่เปลี่ยน** ใบต้นทุนที่บันทึกไปแล้ว / **วัสดุจากสต็อก**: หน้าต่างเพิ่มบรรทัดมีช่องเลือกวัสดุ (`CostState.materialsFor(productId)` = สินค้าที่ไม่ขาย ไม่ใช่ตัวเอง โชว์ราคา + คงเหลือ) เลือกแล้วใส่ชื่อ / หน่วย / ราคาจากวัสดุให้และล็อกหน่วย + ราคา (`CostItemModel.materialId`, ป้าย "จากสต็อก") — API ใช้ทุนของวัสดุจริงเสมอ และคิดใหม่ให้เองเมื่อทุนวัสดุเปลี่ยน — ร้านปิด `useCostPage` → ซ่อนเมนูนี้ |
| ประวัติสต็อก | `/stock` | `StockBloc` | ประวัติรับเข้า / เบิกออก / ขาย ล่าสุดก่อน (แถวที่ API ตัด / คืนวัสดุให้ `isMaterial` มีป้าย "ใช้ผลิต" / "คืนวัสดุ" / แถวที่ขาย `isSale` มีป้าย "ขาย") + **คอลัมน์กำไร** (`hasProfit` จาก API: กำไรสีเขียว / ขาดทุนสีแดง + "ขาย … · ทุน …" ข้างล่าง / แถวอื่นและบิลที่ยกเลิกแล้ว = —) + ปุ่มรับเข้า / เบิกออก (ใส่ต้นทุนต่อหน่วย + ผู้ขายได้ API คิดต้นทุนเฉลี่ย) — รับเข้ามีช่องติ๊ก "ตัดวัสดุที่ใช้ผลิตตามใบต้นทุน" (ค่าเริ่มต้นติ๊ก, ไม่ติ๊ก = ส่ง `skip_materials`) วัสดุไม่พอ → ข้อความบอกวัสดุ / ต้องใช้ / มีอยู่ หน้าต่างไม่ปิด (`saveErrorParams`) — คงเหลือดูที่รายการสินค้า |
| รายรับ-รายจ่าย | `/transactions` | `TransactionBloc` | หมวดเป็นรหัส (`TransactionModel.incomeCategories / expenseCategories`) แสดงด้วย `'transaction.category.<code>'.tr` / การ์ดสรุป 4 ใบ: รายได้ (ก่อน VAT) → ต้นทุนสินค้าที่ขาย → รายจ่าย (ไม่รวมซื้อวัตถุดิบ) → กำไรสุทธิ — **API คิดให้** (`TransactionSummaryModel`) หน้าเว็บไม่คิดกำไรเอง |

**กำไร** (API คิด ดู `../api-Costbook/docs/ARCHITECTURE.md` หัวข้อ 10): รายได้ = ยอดขายก่อน VAT + รายรับที่บันทึกเอง / กำไรขั้นต้น = ยอดขาย − ต้นทุนสินค้าที่ขาย / กำไรสุทธิ (`profit`) = รายได้ − ต้นทุนสินค้าที่ขาย − รายจ่ายที่ไม่ใช่ซื้อวัตถุดิบ — `income` / `expense` คือเงินเข้า-ออกตามที่บันทึก **ห้ามเอามาลบกันเป็นกำไร** / กราฟ 6 เดือน: รายได้ (`revenue`), ต้นทุน + รายจ่าย (`MonthTotalsModel.totalCost`), กำไรสุทธิ

**หน้า login กับระบบจำรหัสของ browser**: `AutofillGroup(onDisposeAction: cancel)` + เรียก `TextInput.finishAutofillContext()` ตอน login สำเร็จก่อน `context.go` → Chrome ถามบันทึกรหัสครั้งเดียวตอน login (ถ้ารอส่งตอนปิดหน้า Chrome จะเดาจากการเปลี่ยนหน้า แล้วถามตอนเปลี่ยนหน้า)
| เอกสารขาย | `/invoices`, `/invoices/create`, `/invoices/:id` | `InvoiceListBloc`, `InvoiceFormBloc`, `InvoiceDetailBloc` | ออกใบสำเร็จ → ไปหน้าดูใบ (`AppRoutes.invoiceDetailPath(id)`), ร้านจด VAT ได้ใบกำกับภาษี ไม่จด ได้ใบเสร็จรับเงิน |
| ตั้งค่า | `/settings` | `SettingsBloc` (จาก shell) + `LanguageBloc` + `AssistantBloc` (key AI) | ข้อมูลร้าน, รูปแบบร้าน, ช่องข้อมูลเพิ่มเติมของสินค้า, key ของ Claude, โลโก้, ภาษา — ร้านจด VAT ต้องกรอกเลขผู้เสียภาษีก่อนออกใบกำกับ / **โลโก้** (`LogoSection`): เลือก / เปลี่ยนรูป (`ImagePickHelper` ย่อให้, เกิน 1 MB เตือนไม่ส่ง) → `LogoUploaded` → `PUT /company/logo` / ลบ (ถามยืนยัน) → `LogoRemoved` → `DELETE` แล้วโหลดข้อมูลร้านใหม่ (`logoStatus` / `logoErrorCode`) — สำเร็จแล้วเรียก `ShopLogo.refresh()`: URL โลโก้มี `?v=<เลข>` เปลี่ยนเลข → โลโก้ทุกที่ (เมนู / หน้า login / ใบกำกับ) โหลดรูปใหม่ทันที ไม่ใช้รูปเก่าที่ Flutter จำไว้ (favicon บนแท็บ browser เปลี่ยนเมื่อ refresh) |

| โปรไฟล์ | `/profile` | `ProfileBloc` (จาก shell) | เปิดจากแถวผู้ใช้ด้านล่างเมนู (เหนือออกจากระบบ) / รูปโปรไฟล์ (เพิ่ม / เปลี่ยน / ลบ แบบเดียวกับโลโก้), ชื่อ-นามสกุล (อีเมลแก้ไม่ได้), เปลี่ยนรหัสผ่าน (ต้องใส่รหัสเดิม, ใหม่ ≥ 6 ตัว + ยืนยันให้ตรง) / เจ้าของร้านมีการ์ด "จัดการผู้ใช้" |
| จัดการผู้ใช้ | `/profile/users` | `UserListBloc` + `ProfileBloc` | เฉพาะเจ้าของร้าน (คนอื่นเปิดมาได้ 403 `forbidden` → ขึ้นรูปกุญแจ "ไม่มีสิทธิ์") / ตาราง: รูป + ชื่อ + อีเมล, ตำแหน่ง, สถานะ / เพิ่มผู้ใช้ (อีเมล + รหัสแรก + ตำแหน่ง), แก้ชื่อ / ตำแหน่ง / เปิด-ปิดบัญชี, ตั้งรหัสใหม่ให้ / **แก้บัญชีตัวเอง เปลี่ยนตำแหน่ง / ปิดบัญชีไม่ได้** (กันล็อกตัวเองออก) / บันทึกแล้วโหลด `ProfileBloc` ใหม่ (เผื่อแก้ชื่อตัวเอง) |

**ผู้ใช้ + role** (API `000014_user_roles`):

- `ProfileBloc` สร้างที่ shell → `GET /auth/me` ครั้งเดียว ใช้ทั้งแถวผู้ใช้ในเมนู (`SideMenuProfile` ส่งผ่าน `PageLayout` → `AppSideMenu`: รูปมีขอบขาว + ชื่อ + ตำแหน่ง / เมนูแบบแคบเหลือแต่รูป) และหน้าโปรไฟล์ → แก้ชื่อ / รูปแล้วเมนูเปลี่ยนตามทันที
- `UserModel.role` เป็น enum `UserRole` (`core/constants/user_role.dart`) — role ที่ไม่รู้จัก = `staff` (สิทธิ์น้อยสุด) / `isOwner` ใช้ซ่อนการ์ดจัดการผู้ใช้
- **ยังไม่ได้ซ่อนเมนูตาม role** (ทุก role เห็นทุกเมนู) — จะทำตอนผู้ใช้กำหนดสิทธิ์: กรองใน `AppMenu.itemsFor(...)` ด้วย role จาก `ProfileBloc` / API ต้องจำกัดด้วย `RequireRole` ด้วยเสมอ (ซ่อนเมนูอย่างเดียวไม่ปลอดภัย)
- รูปโปรไฟล์: `UserAvatar` โหลด `/users/{id}/avatar?v=<avatarVersion>` (ส่ง token ผ่าน `ApiClient.authHeaders`) / ไม่มีรูป = วงกลมส้ม + ตัวอักษรย่อ (`NameUtil.initialOf`: ชื่อขึ้นต้นด้วยสระ เ แ โ ใ ไ เอาพยัญชนะตัวถัดไปด้วย)
- หน้าที่ไม่อยู่ในรายการเมนู (โปรไฟล์ / จัดการผู้ใช้) ตั้งชื่อหน้าใน `AppMenu._otherPageTitleKeys`
- ปิดบัญชีแล้ว → API ตอบ 401 ทันที → `ApiClient.onUnauthorized` พาไปหน้า login / login ไม่ได้ขึ้น `error.user_disabled`

**แชทผู้ช่วย AI (ลอยทุกหน้า เหมือน Messenger)** — ไม่มี route ของตัวเอง:

- `AppShell` = `Stack(PageLayout, ChatLauncher)` → ปุ่มแชทอยู่ทุกหน้าที่อยู่ใน `ShellRoute` (หน้า login ไม่อยู่ใน shell → ไม่มีปุ่ม)
- `ChatLauncher`: ปิดอยู่ = ปุ่มกลมสีส้มมุมขวาล่าง (มีจุดแดงเมื่อ AI ตอบตอนย่ออยู่ `hasUnread`) / เปิด = หน้าต่าง `ChatPanel` 400 × 620 มุมขวาล่าง (จอใหญ่) หรือเต็มจอ (มือถือ)
- เปิด / ย่อด้วย event `AssistantPanelOpened` / `AssistantPanelClosed` (state `isOpen`) — แชทอยู่ใน `AssistantBloc` ที่ shell เปลี่ยนหน้าแล้วยังอยู่ (หายเมื่อ refresh / logout)
- ส่งประวัติแชททั้งหมดทุกครั้ง (`ChatMessageModel.toApi`) งานที่ AI เสนอขึ้นเป็นการ์ด กด "ยืนยัน ทำเลย" → bloc เรียก repository เส้นเดิม (สินค้า / สต็อก / รายรับ-รายจ่าย / เช็คตลาด) แล้วจดผล (`note`) ส่งให้ AI รู้ในคำถามถัดไป
- `PageContent` เว้นที่ด้านล่างเพิ่ม `AppSizes.chatLauncherSpace` → ปุ่มแชทไม่บังปุ่ม / ข้อมูลแถวสุดท้าย

**AI ตัวไหน** (`GET /ai/status` → `AiStatusModel`, โหลดตอนเปิด shell):

| `provider` | มาจาก | แชท | เช็คราคาตลาด (`webSearch`) |
|---|---|---|---|
| `claude` | key ที่ร้านใส่ในตั้งค่า (`hasOwnKey`, โชว์ 4 ตัวท้าย `keyHint`) หรือ `ANTHROPIC_API_KEY` ของ API | ได้ | ได้ |
| `gemini` | `GEMINI_API_KEY` ของ API = **AI ฟรี ค่าเริ่มต้น** (`isFree`) | ได้ | ไม่ได้ → `MarketBloc.canCheck` = false ปิดปุ่มเช็คใหม่ (ผลเก่ายังดูได้) |
| `none` | ไม่มี key เลย | ไม่ได้ (ปิดช่องพิมพ์ + ขึ้นคำแนะนำ) | ไม่ได้ |

- ตั้งค่า → `AiKeySection`: บันทึก (`AssistantKeySaved` → `PUT /ai/key`) / ลบ (`AssistantKeyRemoved` → `DELETE /ai/key`, ถามยืนยันก่อน) → API ตอบสถานะใหม่กลับมา bloc ใช้ค่านั้นเลย ไม่ต้องโหลดใหม่ (`keyStatus` / `keyErrorCode`)
- key ไม่เคยเก็บในเครื่อง ไม่แสดงกลับ (API ส่งมาแค่ 4 ตัวท้าย)

**รูปแบบร้าน** (ตั้งในหน้าตั้งค่า เก็บใน `CompanyModel`) — ทุกหน้าที่เกี่ยวกับเงินต้องดูค่านี้:

| ค่า | ผลในแอป |
|---|---|
| `vatRegistered` | `false` → ออกใบเสร็จ (ไม่มี VAT, ไม่ต้องมีชื่อลูกค้า / เลขผู้เสียภาษี), หน้าคำนวณต้นทุนไม่พูดถึง VAT |
| `pricesIncludeVat` | `true` → ราคาขายรวม VAT แล้ว: ยอดในบิลถอด VAT ออก, หน้าต้นทุนคิดกำไร / markup จากราคาก่อน VAT, ปุ่ม "คำนวณราคาขาย" บวก VAT ให้ |
| `priceHasVat` (getter) | `vatRegistered && pricesIncludeVat` — ใช้ตัวนี้เวลาถามว่า "ราคาที่ตั้งไว้มี VAT อยู่ข้างในไหม" |
| `useCostPage` | `false` → ซ่อนเมนูคำนวณต้นทุน (`AppMenu.itemsFor(useCostPage:)`) |

**ช่องข้อมูลเพิ่มเติม** (`ProductFieldModel`): ร้านเพิ่มช่องเอง (ข้อความ / ตัวเลข / วันที่ / ตัวเลือก) ในหน้าตั้งค่า → ฟอร์มสินค้าแสดงช่องให้กรอก (`CustomFieldInput`) → เก็บใน `ProductModel.customFields` (`{id ช่อง: ค่า}`)

ผลของการบันทึก / ลบ แยกเป็น field ของ state: `saveStatus` / `saveErrorCode` (กล่องฟอร์มใช้ — สำเร็จแล้วปิดเอง ไม่สำเร็จแสดง error ในกล่อง) และ `deleteStatus` / `deleteErrorCode` (หน้าใช้ — แสดง snackbar)
กล่องฟอร์มเปิดด้วย `XxxDialog.show(context, ...)` ซึ่งส่ง bloc ของหน้าเข้าไปด้วย `BlocProvider.value`

**Dialog ทุกตัวใช้โครงเดียวกัน** (ห้ามใช้ `AlertDialog` ตรง ๆ):

| ใช้ทำอะไร | widget | หน้าตา |
|---|---|---|
| ฟอร์มเพิ่ม / แก้ข้อมูล | `FormDialog` (ใส่ `icon` ทุกครั้ง) | หัว: ไอคอนในกล่องสีส้ม + ชื่อ + ปุ่ม ✕ → เนื้อหาเลื่อนได้ (แถบเลื่อนขึ้นเมื่อยาวเกิน) → กล่อง error สีแดงเหนือปุ่ม → แถบปุ่มสีเทาอ่อน (ยกเลิก = ปุ่มขอบ, บันทึก = ปุ่มส้ม) |
| หน้าต่างอื่นที่มีรายการ / ปุ่มเอง | `AppDialog` | โครงเดียวกับ `FormDialog` ส่ง `actions` เอง (เช่น `CostPresetsDialog`) |
| ถามยืนยันก่อนลบ / ยกเลิก | `DialogHelper.confirm(icon:)` → `AppAlertDialog` | ไอคอนวงกลมสีแดงตรงกลาง + ชื่อ + ข้อความ + ปุ่ม ยกเลิก / ยืนยัน (สีแดง) กว้างเท่ากัน |
| แจ้งว่าทำสำเร็จ | `AppAlertDialog(isDanger: false)` | แบบเดียวกันแต่สีเขียว ปุ่มหลักสีส้ม (เช่น ขายแล้วในหน้าขายด่วน) |

- พื้น dialog สีขาว ไม่ย้อมสีส้มตามธีม + ฉากหลังมืด (`AppTheme._dialogTheme`, ปฏิทินเลือกวันที่ใช้แบบเดียวกัน)
- มือถือ: ขอบจอแคบลง (`AppSizes.dialogMobileInset`) และปุ่มด้านล่างกว้างเท่ากัน
- `AppButton(variant:)`: `primary` (ส้ม), `secondary` (ปุ่มขอบ), `danger` (แดง) + ใส่ `icon` ได้ — หน้าตามาจากธีม (ดูหัวข้อ 8 "ปุ่มทุกแบบ")

ลองหน้าจอกับ API อื่นที่ไม่ใช่ `http://localhost:8080/api/v1` (เช่น server จริง / API ทดสอบ):
`flutter build web --dart-define=API_URL=https://api.example.com/api/v1` (favicon ใน `web/index.html` ต้องแก้เอง)

---

## 8. Widget แบบ Atomic Design

| ระดับ | คืออะไร | import ได้จาก | ตัวอย่าง |
|---|---|---|---|
| **atoms** | ชิ้นเล็กสุด ใช้ซ้ำทุกที่ | Flutter เท่านั้น | `AppButton`, `AppTextField`, `AppDropdown`, `AppLoading`, `AppBadge`, `MoneyText` |
| **molecules** | atoms หลายตัวรวมกัน | atoms | `SearchField`, `StatCard`, `AmountRow`, `EmptyView`, `ErrorView` |

**เนื้อหาของทุกหน้า** (`PageContent` — ทุกหน้ายกเว้น login): เลื่อนขึ้นลงได้ / `header:` = แถบบนติดอยู่กับที่ตอนเลื่อน (มีเส้นบาง ๆ ใต้แถบเมื่อเลื่อนแล้ว) ใช้กับปุ่มกลับ: เช็คราคาตลาด, ออกเอกสารขาย, ดูเอกสารขาย (ทั้งแถบปุ่ม พิมพ์ / ดาวน์โหลด) / เลื่อนลงเกิน `AppSizes.scrollTopThreshold` → ปุ่มลูกศรกลม (`FloatingActionButton.small`) มุมขวาล่าง กึ่งกลางเหนือปุ่มแชท (`scrollTopRight` / `scrollTopBottom` คิดจากขนาดปุ่มแชท) กดแล้วเลื่อนกลับขึ้นบนสุด

**การ์ดตัวเลขสรุป** (`StatCard` ใน `StatGrid`): ไอคอน + ชื่อ อยู่บน → ตัวเลขใหญ่ (`AppSizes.kpiFont` สีเข้ม, ยาวเกินย่อเอง) → คำอธิบาย (ไม่เกิน 2 บรรทัด) เรียงจากบนแบบเดียวกันทุกใบ ตัวเลขจึงอยู่ระดับเดียวกัน + แถบสัดส่วนชิดล่าง (`share` = %, `shareLabel`; ราง = สีเดียวกันแบบอ่อน, `PercentUtil.fraction` แปลง % เป็นความยาว) / การ์ดผลลัพธ์ของหน้า (1 ใบต่อหน้า) ใส่ `isHighlighted: true` → พื้นเข้มไล่สี + ตัวเลขใหญ่สีขาว + แถบเฉียงสีที่มุมขวาบนแบบหน้า login (`_CornerStripesPainter`) เช่น กำไรสุทธิ, ราคาแนะนำ — ขาดทุนส่ง `valueColor: AppColors.dangerOnDark` — `StatGrid` วางเป็นแถว การ์ดในแถวเดียวกัน**สูงเท่ากัน** (`IntrinsicHeight` + `Row` stretch) และเกลี่ยจำนวนต่อแถวให้เท่า ๆ กัน (`ResponsiveUtil.gridColumns`: 4 ใบ จอพอ 3 คอลัมน์ → 2 × 2)
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
   - เมนูกลุ่ม = `AppMenuItem(children: [...])` กดแล้วกาง / หุบ (ตัวกลุ่มไม่มีหน้า) กางเองเมื่อหน้าปัจจุบันอยู่ข้างใน / เมนูย่อยที่ถูกเลือก = `selectedChild` (route ที่ตรงและยาวสุด) / แถบบนใช้ชื่อเมนูย่อย / เมนูแบบแคบแสดงเมนูย่อยเป็นไอคอนเรียงกัน
   - ตอนนี้มีกลุ่มเดียว: **สินค้าและสต็อก** → รายการสินค้า / ประวัติสต็อก / หมวดหมู่สินค้า (วัสดุอยู่ในรายการสินค้า กรองด้วยปุ่ม "วัสดุ")
8. หน้าที่ยังไม่ได้ทำใช้ `ComingSoonView` (molecules) บอกว่าหน้านั้นจะทำอะไร

```dart
// lib/shared/widgets/atoms/app_button.dart
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary, // primary / secondary / danger
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;

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

**ปุ่มทุกแบบ หน้าตามาจากธีมที่เดียว** (`core/theme/app_theme.dart`) — ในหน้าจอใช้ `FilledButton` / `OutlinedButton` / `TextButton` / `SegmentedButton` / `ChoiceChip` ตรง ๆ ได้เลย **ห้ามใส่ขนาด / มุมโค้ง / ตัวหนังสือเอง** (เปลี่ยนแค่สีได้ เช่น ปุ่มรายรับสีเขียว)

| ปุ่ม | ใช้ตอนไหน | หน้าตา |
|---|---|---|
| `FilledButton` / `AppButton` primary | ปุ่มหลักของหน้า / dialog (เพิ่ม, บันทึก, ขายสินค้า) | พื้นส้ม ตัวหนังสือเข้ม |
| `OutlinedButton` / `AppButton` secondary | ปุ่มรอง (รับเข้า, เบิกออก, ยกเลิก) | พื้นขาว ขอบเทาอ่อน ตัวหนังสือเข้ม ไอคอนส้ม |
| `TextButton` | ลิงก์ในการ์ด (ดูทั้งหมด, + เพิ่มรายการ, กลับ) | ตัวหนังสือส้มเข้ม (`AppColors.primaryDark` อ่านง่ายกว่าส้มบนพื้นขาว) |
| `AppTabs` (molecules) | สลับมุมมองของรายการ (ทั้งหมด / สินค้าขาย / วัสดุ) — ใส่ใน `AppDataTable(header:)` / สลับฟอร์มใน dialog (รับเข้า / เบิกออก) — ใส่ใน `FormDialog(tabs:)` + `selectedColor: AppColors.surface` | แท็บแบบแฟ้มบนแถบเทา: ที่เลือก = สีเดียวกับหัวตาราง (ต่อกันเป็นแผ่นเดียว) + เส้นส้มด้านบน + ตัวหนังสือส้มเข้ม + จำนวน / มือถือไม่แสดงไอคอน |
| `SegmentedButton` | เลือก 1 จากไม่กี่แบบในฟอร์ม (รายรับ / รายจ่าย, จำนวน × ราคา / %, ภาษา) | ที่เลือกอยู่ = พื้นส้มอ่อน ตัวหนังสือส้มเข้ม — ใส่ `showSelectedIcon: false` ทุกครั้ง |
| `ChoiceChip` / `FilterChip` | ตัวกรอง (หมวด, เฉพาะใกล้หมด) | ทรงแคปซูล ไม่มีเครื่องหมายถูก ที่เลือกอยู่ = ขอบส้ม พื้นส้มอ่อน |
| `IconButton` | ปุ่มไอคอนในตาราง (แก้ / ลบ) | ชี้เมาส์มีพื้นสี่เหลี่ยมมุมโค้ง |
| `PopupMenuButton` (⋮) | ปุ่มที่ใช้ไม่บ่อยท้ายแถวตาราง (เช็คราคา / แก้ / ลบ) เมื่อปุ่มเยอะจนเบียดคอลัมน์อื่น | พื้นขาว ขอบเทา มุมโค้ง (ธีม `popupMenuTheme`) ไอคอน + ข้อความ / ลบ = สีแดง |
| `Switch` | เปิด / ปิด | ปุ่มกลมขาว รางส้ม (เปิด) / เทา (ปิด) |

- ปุ่ม / SegmentedButton สูง `AppSizes.buttonHeight` (48) **เท่าช่องกรอก** วางข้างช่องค้นหาแล้วเสมอกัน, มุมโค้ง `AppSizes.radius` เท่าช่องกรอก, ตัวหนังสือ `AppSizes.fontButton` ตัวหนา, ชี้เมาส์แล้วปุ่มลอยขึ้นนิดหน่อย (`_hoverLift`)
- Flutter บนเว็บจอคอมย่อปุ่มเอง (`VisualDensity.compact` → ปุ่มเหลือ 32) → ธีมใส่ `VisualDensity.standard` ให้ปุ่มทุกแบบ / `SegmentedButton` ไม่ส่ง `minimumSize` ต่อให้ปุ่มย่อย → ใช้ `VisualDensity(vertical: 2)` แทน (40 + 2 × 4 = 48) — `test/core/theme/app_theme_test.dart` เช็คความสูงแบบจำลองจอคอม
- `MonthSwitcher` สูง / ขอบเท่าปุ่มรอง

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

### กราฟ (หน้าภาพรวม)

- ใช้ `fl_chart` 3 กราฟ: เส้นยอดขายสะสม (เดือนนี้เส้นทึบ + พื้นจาง / เดือนก่อนเส้นประสีเทา), แท่งวันในสัปดาห์ (วันที่ขายดีสุดสีน้ำเงิน ที่เหลือสีเทา), เส้นย้อนหลัง 6 เดือน — ส่วนแท่งตามหมวด / แถบราคาตลาด / เกจ margin เป็น widget ธรรมดา (`RankedBarList`, `MarketRangeBar`, `MarginGauge` วาดด้วย `CustomPaint`)
- ยอดรายวันมีหลายวันที่เป็น 0 → กราฟยอดขายใช้ยอด **สะสม** (`ChartUtil.cumulative`) อ่านง่ายกว่า และเทียบเดือนก่อน ณ วันเดียวกันได้ / เดือนปัจจุบันวาดถึงวันนี้
- สีกราฟอยู่ใน `AppColors.chart*`: รายรับ / ยอดขาย = น้ำเงิน, รายจ่าย = ส้ม, กำไร = เขียวอมฟ้า (ผ่านตัวตรวจสีสำหรับคนตาบอดสี) — สีเดียวกันหมายถึงเรื่องเดียวกันทุกกราฟ
- เส้นสีเขียวอมฟ้าตัดกับพื้นขาวน้อย → ใต้กราฟย้อนหลังต้องมีตารางตัวเลข (บนมือถือพับไว้ "ดูตัวเลขรายเดือน")
- แกน y ใช้ `ChartUtil.range` (เริ่มที่ 0 มีค่าติดลบได้ ปัดเป็นเลขกลม) + `ChartUtil.axisLabel` (ถึง 10,000 ใช้ K ทั้งแกน)
- ชี้ที่แท่ง / จุด มีกล่องบอกตัวเลข (tooltip ของ fl_chart) / ข้อความในกราฟใช้สีตัวหนังสือ ไม่ใช้สีของเส้น

## 9. Utils และ Helpers

| | Utils (`core/utils`) | Helpers (`core/helpers`) |
|---|---|---|
| คืออะไร | ฟังก์ชันคำนวณ / แปลงค่า | ฟังก์ชันช่วยงาน UI / plugin |
| ใช้ BuildContext | ไม่ใช้ | ใช้ได้ |
| เขียน test | **บังคับ** | ไม่บังคับ |
| ตัวอย่าง | `MoneyUtil`, `TaxUtil`, `CostUtil`, `DateUtil`, `ValidatorUtil`, `PercentUtil`, `MarketUtil`, `ChartUtil` | `DialogHelper`, `SnackbarHelper`, `PdfHelper` |

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
  // ถามยืนยันก่อนทำสิ่งที่ย้อนกลับไม่ได้ (ลบ / ยกเลิก) → true = กดยืนยัน
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    IconData icon = Icons.delete_outline,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppAlertDialog(
        icon: icon,
        title: title,
        message: message,
        primaryText: confirmText,
        onPrimary: () => Navigator.pop(dialogContext, true),
        secondaryText: 'common.cancel'.tr,
        onSecondary: () => Navigator.pop(dialogContext, false),
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
| บรรทัดต้นทุนแบบ จำนวน × ราคา | จำนวน × ราคาต่อหน่วย (`CostUtil.lineAmount`) เช่น 160 กรัม × 0.45 = 72 |
| บรรทัดต้นทุนแบบ % | % × ผลรวมบรรทัดแบบ จำนวน × ราคา ทั้งใบ ÷ 100 (`CostUtil.percentOf`) |
| ต้นทุนรวม | วัตถุดิบ + ค่าแรง + ค่าใช้จ่ายอื่น |
| ต้นทุนต่อหน่วย | ต้นทุนรวม ÷ จำนวนที่ผลิตได้ |
| ราคาขาย | ต้นทุนต่อหน่วย × (1 + markup% ÷ 100) — ร้านตั้งราคารวม VAT → บวก VAT ต่อ |
| กำไรต่อหน่วย | ราคาขาย (ก่อน VAT) − ต้นทุนต่อหน่วย — ราคารวม VAT ต้องถอด VAT ออกก่อน (`CostSheetModel.netSellPrice`) เพราะ VAT ไม่ใช่เงินของร้าน |
| VAT | ราคาก่อน VAT × 7 ÷ 100 |
| ถอด VAT จากราคารวม | ราคารวม × 100 ÷ 107 |
| % เทียบเดือนก่อน | (เดือนนี้ − เดือนก่อน) ÷ \|เดือนก่อน\| × 100 (`PercentUtil.change`) เดือนก่อนเป็น 0 = เทียบไม่ได้ |
| กำไรขั้นต้น / margin | ยอดขายก่อน VAT − ต้นทุน ณ วันที่ขาย / ÷ ยอดขาย × 100 (API คิดให้) |
| เทียบราคาตลาด | ราคาที่ลูกค้าจ่าย (`MarketUtil.customerPrice`: จด VAT + ราคาไม่รวม VAT → บวก VAT) เทียบช่วงราคาปลีก → ถูกกว่า / อยู่ในช่วง / แพงกว่า |
| ยอดในเอกสารขาย | `TaxUtil.documentAmounts`: รวมสินค้า − ส่วนลด → ใบเสร็จ: ไม่มี VAT / ราคารวม VAT: ถอด VAT / ราคาไม่รวม VAT: บวก VAT (คิดทั้งใบ ไม่คิดทีละบรรทัด ตรงกับ API) |
| stock คงเหลือ | รับเข้า − เบิกออก |
| ใกล้หมด | คงเหลือ ≤ จำนวนขั้นต่ำ (minStock) |

- เงินปัดเศษ 2 ตำแหน่งด้วย `MoneyUtil.round2` ทุกครั้งที่คำนวณเสร็จ
- สูตรทุกตัวอยู่ใน `core/utils` และต้องมี unit test

**ใบเสร็จรับเงิน** (ร้านไม่จด VAT): หัวกระดาษ "ใบเสร็จรับเงิน", เลข `RC-2026-0001`, ไม่มี VAT, ไม่มีเลขผู้เสียภาษีถ้าร้านไม่ได้กรอก, ไม่ใส่ชื่อลูกค้า = "ลูกค้าทั่วไป", ช่องเซ็นชื่อ "ผู้รับเงิน"
**ใบกำกับภาษีอย่างย่อ** ยังไม่ทำ (ผู้ใช้บอกว่ายังไม่ต้อง)

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
