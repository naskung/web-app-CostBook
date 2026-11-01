# CostBook Web — ความคืบหน้า

> ทุกครั้งที่ทำงานเสร็จ: ติ๊ก `[x]` ในรายการ และเพิ่ม 1 บรรทัดใน "บันทึกการทำงาน" (ล่าสุดอยู่บนสุด)

## สถานะตอนนี้

- **เสร็จแล้ว:** Phase 0–3, **ทุกเมนูต่อ API จริงแล้ว** (ภาพรวม, ขายด่วน, สินค้า, คำนวณต้นทุน, สต็อก, รายรับ-รายจ่าย, เอกสารขาย + พิมพ์ / PDF, ตั้งค่า + เปลี่ยนภาษา), token หมดอายุ → กลับหน้า login
- **ภาพรวมแบบละเอียด + AI:** กราฟยอดขายรายวัน / ย้อนหลัง 6 เดือน, % เทียบเดือนก่อน, กำไรขั้นต้น, ขายดี, ตามหมวด, มูลค่าสต็อก, เทียบราคาตลาด / หน้าเช็คราคาตลาดด้วย AI / แชทผู้ช่วย AI (เสนองาน → กดยืนยัน)
- **แชท AI แบบลอย (เหมือน Messenger):** ปุ่มกลมมุมขวาล่างทุกหน้า (ยกเว้น login) กดแล้วเปิดหน้าต่างแชท (มือถือเต็มจอ) / ตั้งค่า → ใส่ key ของ Claude เองได้ ไม่ใส่ = ใช้ **Gemini ฟรี** (แชทได้ เช็คราคาตลาดไม่ได้) — **ยังไม่ได้ลองให้ AI ตอบจริง** (รอ key)
- **รองรับร้านหลายแบบ:** จด / ไม่จด VAT (ใบกำกับ / ใบเสร็จ), ราคารวม VAT แล้ว, ซ่อนหน้าต้นทุน, ช่องข้อมูลสินค้าที่ร้านเพิ่มเอง, ต้นทุนแบบ จำนวน × ราคา / %, งานบริการไม่นับสต็อก
- **งานถัดไป:** รอผู้ใช้สั่ง — เช่น อัปโหลดโลโก้จากหน้าตั้งค่า (ต้องเพิ่ม package เลือกไฟล์), ปฏิทินเลือกวันที่เป็นภาษาไทย, ใบกำกับหลายหน้า, deploy

---

## Phase 0 — เอกสารและกติกา

- [x] โครงสร้างและกติกาโปรเจกต์ `docs/ARCHITECTURE.md`
- [x] `CLAUDE.md` (กฎที่ Claude อ่านทุกครั้ง)
- [x] skill `simple-code` — เขียนโค้ดแบบง่าย ไม่ซับซ้อน
- [x] skill `unit-test-check` — ตรวจ / รัน / เขียน unit test
- [x] `PROGRESS.md` (ไฟล์นี้)

## Phase 1 — ตั้งค่าโปรเจกต์

- [x] `flutter create --platforms web --project-name costbook .`
- [x] เพิ่ม package สำหรับ login: flutter_bloc, equatable, http, go_router, shared_preferences, bloc_test, mocktail
- [x] เพิ่ม package ที่เหลือ: intl, pdf, printing (+ `dependency_overrides: image: 4.5.4` ให้ pdf compile ได้)
- [x] สร้างโฟลเดอร์ตาม `docs/ARCHITECTURE.md` (โฟลเดอร์ว่างมี `.gitkeep` ลบได้เมื่อมีไฟล์จริง)

## Phase 2 — Core

- [x] theme: `AppColors`, `AppSizes`, `AppTheme` + ฟอนต์ LINESeedSansTH
- [x] รองรับทุกขนาดจอ: `ScreenType`, `ResponsiveUtil` + test, `ResponsiveHelper`, `ScreenScaler` (จอใหญ่ขยายทั้งแอป) + test
- [x] `AppStatus`
- [x] ภาษา: `AppLang` + `.tr` + `th.json` / `en.json`
- [x] `LanguageBloc` (เปลี่ยนภาษาในหน้าตั้งค่า + จำไว้ในเครื่อง)
- [x] route: `AppRoutes` + `appRouter` (`/login`, `/` + redirect ตาม token)
- [x] route: ShellRoute + `AppShell` + `PageLayout` + เมนู 7 หน้า (`AppMenu`) + แอนิเมชันซูม (`AppPageTransition`)
- [x] `ApiClient` (`get` / `post` / `put` / `delete` + แนบ token ให้เอง + `ApiException` + 401 → `onUnauthorized`) + test
- [x] utils + test: `ValidatorUtil` (required, email)
- [x] utils + test: `MoneyUtil`, `TaxUtil`, `CostUtil`, `DateUtil`, `ErrorUtil`, `ValidatorUtil` (เพิ่ม taxId, ตัวเลข)
- [x] helpers: `DialogHelper`, `SnackbarHelper`, `PdfHelper`
- [x] test เช็ค key ภาษา th / en ตรงกัน

## Phase 3 — Widget กลาง

- [x] atoms: `AppButton` (มี `isLoading`), `AppTextField` (มีปุ่มแสดง / ซ่อนรหัสผ่าน)
- [x] atoms: `AppDropdown`, `AppLoading`, `AppBadge`, `MoneyText`
- [x] molecules: `SearchField`, `StatCard`, `EmptyView`, `ErrorView`, `MonthSwitcher`, `SectionCard`, `NoticeBanner` (`AmountRow` ไม่ได้ใช้ ไม่ได้ทำ)
- [x] atoms: `ShopLogo` (โลโก้ร้านจาก API ใช้ทั้งหน้า login และเมนู)
- [x] ~~molecules: `ComingSoonView`~~ ลบแล้ว (ทุกหน้ามีของจริงแล้ว)
- [x] organisms: `PageLayout`, `AppSideMenu` (แถบบนใช้ `AppBar` + `appBarTheme` แทน `AppTopBar`)
- [x] organisms: `AppDataTable` (จอคอม = ตาราง / มือถือ = การ์ด), `FormDialog`, `PageContent`, `PageToolbar`, `StatGrid`

## Phase 4 — Features

แต่ละ feature: model + test → repository → bloc + test → pages → widgets

- [x] auth — login: UI + `AuthBloc` + `AuthRepository` + ต่อ API `POST /auth/login` + route `/login` + จดจำ token (`shared_preferences`) + logout + test
- [x] auth — หน้า login แสดงโลโก้ร้านจาก `GET /company/logo` (โหลดไม่ได้ → ไอคอน CostBook) + favicon ใช้โลโก้ร้าน
- [x] auth — ได้ 401 `unauthorized` → ลบ token แล้วไปหน้า login
- [x] product — รายการ / ค้นหา / เพิ่ม / แก้ / ลบ (ป้ายใกล้หมด) + test
- [x] cost — ใบต้นทุน 3 ประเภท + จำนวนผลิตต่อรอบ + markup → ราคาขาย + บันทึกทั้งใบ + test
- [x] stock — คงเหลือ / เฉพาะใกล้หมด / ประวัติ / รับเข้า / เบิกออก + test
- [x] transaction — รายรับ-รายจ่ายรายเดือน + สรุป + หมวด + รายการจากใบกำกับล็อกไว้ + test
- [x] invoice — รายการรายเดือน / ออกใบ (VAT 7% ทั้งใบ) / ดูใบ A4 / พิมพ์ / ดาวน์โหลด PDF (ภาษาไทยถูก) / ยกเลิก + test
- [ ] invoice — ใบที่ยาวเกิน 1 หน้า A4 (ตอนนี้ย่อให้อยู่หน้าเดียว), ตัวหนังสือจำนวนเงิน (บาทถ้วน)
- [x] dashboard — รายรับ / รายจ่าย / กำไร / ใบกำกับ / สินค้า / ใกล้หมด ของเดือน + ทางลัด + test
- [x] ทุกเมนูมีหน้าแล้ว (product / cost / stock / transaction / invoice / settings เป็นหน้า "กำลังพัฒนา" + บอกว่าจะทำอะไร)
- [x] settings — ข้อมูลร้าน (เลขผู้เสียภาษี 13 หลัก) + แสดงโลโก้ + เปลี่ยนภาษา + test
- [ ] settings — อัปโหลด / ลบโลโก้จากหน้าเว็บ (API มีแล้ว ต้องเพิ่ม package เลือกไฟล์ เช่น file_picker)
- [x] รองรับร้านหลายแบบ:
  - [x] settings — รูปแบบร้าน (จด VAT / ราคารวม VAT / ใช้หน้าต้นทุน) + ช่องข้อมูลเพิ่มเติมของสินค้า (เพิ่ม / แก้ / ลบ) + test
  - [x] `SettingsBloc` ย้ายไปไว้ที่ shell → เมนูคำนวณต้นทุนซ่อนได้, ทุกหน้ารู้รูปแบบร้าน
  - [x] product — รหัส / บาร์โค้ด, หมวด (กรองได้), รายละเอียด, นับสต็อกไหม, ช่องเพิ่มเติม (โชว์เป็น column ได้) + test
  - [x] product — รูปสินค้า 1 รูป: เลือก / เปลี่ยน / ลบในฟอร์ม (ย่อรูปให้), แสดงในตารางสินค้า / มือถือ / หน้าขายด่วน + test
  - [x] cost — บรรทัดแบบ จำนวน × ราคาต่อหน่วย หรือ %, รายการที่ใช้บ่อย, กำไร / markup ตามรูปแบบ VAT ของร้าน + test
  - [x] cost — จัดการรายการที่ใช้บ่อย: เพิ่ม / แก้ราคา / ลบ (ยืนยันก่อน) แยกกลุ่มตามประเภท เปิดได้แม้ยังไม่มีสินค้า + test
  - [x] stock — รับเข้าใส่ต้นทุนต่อหน่วย + ผู้ขาย (API คิดต้นทุนเฉลี่ย) + test
  - [x] invoice — ใบเสร็จรับเงิน, ส่วนลดทั้งบิล, ราคารวม VAT, ไม่ต้องมีชื่อลูกค้า (ใบเสร็จ) + test
  - [x] sell — หน้าขายด่วน `/sell` (ค้นหา / สแกนรหัส → บิล → รับเงิน → ขายบิลต่อไป) + ทางลัดในหน้าภาพรวม + test
  - [ ] ใบกำกับภาษีอย่างย่อ (ผู้ใช้บอกว่ายังไม่ต้อง)
- [x] ภาพรวมแบบละเอียด + AI:
  - [x] dashboard — ตัวเลข 8 ช่อง + % เทียบเดือนก่อน, กราฟแท่งรายวัน, กราฟเส้น 6 เดือน + ตาราง, ยอดตามหมวด, รายจ่ายตามหมวด, ขายดี 5 อันดับ + margin, เทียบราคาตลาด + test
  - [x] market — หน้าเช็คราคาตลาด: ขายปลีก / ขายส่ง / ต้นทุนตลาด / ราคาแนะนำ, ราคาเราอยู่ตรงไหน, กำไรต่อหน่วยเรา vs ตลาด, ต้นทุนแยกรายการ, แหล่งที่มา (ปุ่มคัดลอกลิงก์) + test
  - [x] assistant — แชทผู้ช่วย AI + การ์ดงานที่ AI เสนอ (ยืนยัน / ไม่เอา) + แชทอยู่ต่อเมื่อเปลี่ยนหน้า + test
  - [x] สินค้า — ปุ่ม "เช็คราคาตลาดด้วย AI" ทุกแถว / ทางลัด "ถามผู้ช่วย AI"
  - [x] แชทลอยทุกหน้า: ปุ่มมุมขวาล่าง (`ChatLauncher`) + หน้าต่างแชท (`ChatPanel`) แทนเมนู / หน้า `/assistant` เดิม, จุดแดงเมื่อ AI ตอบตอนย่อหน้าต่างอยู่ + test
  - [x] ตั้งค่า — ใส่ / เปลี่ยน / ลบ key ของ Claude (`AiKeySection`), บอกว่าตอนนี้ใช้ AI ตัวไหน + test
  - [x] AI ฟรี (Gemini) เป็นค่าเริ่มต้น — หน้าเช็คราคาตลาดปิดปุ่มเช็คใหม่ + บอกให้ใส่ key ของ Claude (ผลเก่ายังดูได้)
  - [ ] ลองกับ Claude / Gemini จริง (รอ key)
  - [ ] เปิดลิงก์แหล่งที่มาได้ด้วยการกด (ต้องเพิ่ม package เช่น `url_launcher` — ตอนนี้กดคัดลอกลิงก์)

## Phase 5 — ส่งงาน

- [x] ต่อ API จริง (`../api-Costbook`) แทนข้อมูลตัวอย่าง
- [x] `flutter analyze` และ `flutter test` ผ่านทั้งหมด
- [x] `flutter build web`
- [ ] deploy

---

## เรื่องที่ยังต้องตัดสินใจ

- [ ] deploy ที่ไหน (Firebase Hosting / Vercel / server เอง)
- [x] ต้องมี login ไหม → มี (อีเมล + รหัสผ่าน ตาม API)
- [ ] มีผู้ใช้หลายคน / แบ่งสิทธิ์ไหม
- [x] ออกใบกำกับแล้วตัด stock + บันทึกรายรับอัตโนมัติ → API ทำ (ตัดสินใจ 2026-10-31)
- [x] รูปแบบเลขที่ใบกำกับ → API รันเลข `INV-2026-0001` รันใหม่ทุกปี (ตัดสินใจ 2026-10-31) / ใบเสร็จ `RC-2026-0001` แยกเลขกัน
- [x] ร้านอยากเพิ่มข้อมูลสินค้าเอง → ช่องข้อมูลเพิ่มเติม / ต้นทุน → จำนวน × ราคาต่อหน่วย + % + รายการที่ใช้บ่อย / ใบกำกับอย่างย่อ → ยังไม่ทำ (ตัดสินใจ 2026-10-31)

---

## บันทึกการทำงาน

| วันที่ | ทำอะไร | หมายเหตุ |
|---|---|---|
| 2026-11-01 | **แก้การคิดกำไร** (ผู้ใช้แจ้งว่ากำไรแสดงเท่ายอดขาย): หน้ารายรับ-รายจ่ายมีการ์ด 4 ใบ รายได้ (ก่อน VAT) / ต้นทุนสินค้าที่ขาย (+ กำไรขั้นต้น) / รายจ่าย (ไม่รวมซื้อวัตถุดิบ บอกยอดที่ไม่นับไว้) / กำไรสุทธิ, หน้าภาพรวมการ์ดบน รายได้ / กำไรขั้นต้น / กำไรสุทธิ / รายจ่าย (เอาจำนวนบิลออก มีในกล่องยอดขายแล้ว), กราฟ + ตาราง 6 เดือน รายได้ / ต้นทุน + รายจ่าย / กำไรสุทธิ, `TransactionSummaryModel` + `DashboardModel` + `MonthTotalsModel` field ใหม่ (`revenue`, `costOfSales`, `operatingExpense`, `materialExpense` …, `totalCost`), ลบ key ภาษาที่ไม่ใช้ (`transaction.profit`, `dashboard.bills`) th / en 597 คำ / **แก้ Chrome ถามบันทึกรหัสผ่านตอนเปลี่ยนหน้า**: ส่งฟอร์ม login ให้ browser ตอน login สำเร็จ (`TextInput.finishAutofillContext()`) + `AutofillGroup(onDisposeAction: cancel)` | analyze ผ่าน, test 464 ผ่าน — แก้ test หน้าภาพรวม 4 ตัวเพราะ **นิยามเปลี่ยน** (การ์ดรายจ่ายอ่าน `operating_expense`, กำไรสุทธิไม่ใช่ รายรับ − รายจ่าย แล้ว) — ลองใน Chrome 1280 / 375 กับ API + DB ทดสอบ: ตัวเลขตรงกับคิดมือ ✓ — เรื่องรหัสผ่าน: ดูบันทึกของ Chrome (`chrome://password-manager-internals`) เดิม Chrome ถามตอนเปลี่ยนหน้าครั้งแรกหลัง login, หลังแก้ถามทันทีตอน login และเปลี่ยนหน้าอีก 4 ครั้งไม่ถามซ้ำ (ทำซ้ำไม่ได้ว่าถามทุกหน้าแบบที่ผู้ใช้เจอ เพราะทดสอบใน Chrome โปรไฟล์ใหม่) | **ต้อง restart API (`make run`)** / ถ้า Chrome ยังถาม กด "Never" ได้ |
| 2026-11-01 | **รูปสินค้า** (ผู้ใช้ขอ + เลือก image_picker / 1 รูป): เพิ่ม package `image_picker` ^1.2.2, `ImagePickHelper` (ย่อด้านยาว ≤ 1200 px คุณภาพ 85%), `ApiClient.putFile` (multipart) + `ApiClient.authHeaders`, `ApiConstants.productImageUrl`, `ProductModel.imageVersion` / `hasImage` / `imageUrl`, `ProductRepository.uploadImage` / `deleteImage`, `ProductSaved(image:, removeImage:)` + state `imageErrorCode`, widget `AppImageBox` (atoms) + `ProductImage`, ฟอร์มสินค้ามีส่วนรูป (ตัวอย่าง + เลือก / เปลี่ยน / ลบ + เตือนเกิน 1 MB), ตารางสินค้า / การ์ดมือถือมีรูปเล็กหน้าชื่อ, การ์ดหน้าขายด่วนมีรูป, key ภาษา th / en 591 คำ | analyze ผ่าน, test 461 ผ่าน — ลองใน Chrome 1280 / 375 กับ API + DB ทดสอบ: แก้สินค้าแล้วเลือกรูป → ขึ้นตัวอย่าง → บันทึก → ตารางขึ้นรูป ✓, เพิ่มสินค้าใหม่พร้อมรูป ✓, หน้าขายด่วนขึ้นรูป / ไม่มีรูปเป็นกล่องเทา ✓, ลบรูป ✓, รูป 3.6 MB ขึ้นเตือนไม่ส่ง ✓ — เจอแล้วแก้: build เว็บใช้ตัวลงทะเบียน plugin เก่า กดเลือกรูปแล้ว error "No implementation found" → ลบ `.dart_tool/flutter_build` แล้ว build ใหม่ | **ต้อง restart API (`make run`)** / รูป PNG ที่ย่อแล้วยังเกิน 1 MB ส่งไม่ได้ (ระบบบอกให้ใช้ JPG) |
| 2026-11-01 | **ออกแบบ dialog ใหม่ทั้งหมด** (ผู้ใช้ขอให้สวยกว่าเดิม): widget กลางใหม่ `AppDialog` (หัวมีไอคอนกล่องสีส้ม + ชื่อ + คำอธิบาย + ปุ่ม ✕ / เนื้อหาเลื่อนได้มีแถบเลื่อน / แถบปุ่มสีเทาอ่อน / มือถือปุ่มกว้างเท่ากัน) + `AppAlertDialog` (ไอคอนวงกลมตรงกลาง สีแดง = ยืนยันลบ, สีเขียว = สำเร็จ), `FormDialog` ใช้ `AppDialog` + `icon` / `subtitle` + กล่อง error สีแดง, `AppButton` เพิ่ม `variant` (primary / secondary / danger) + `icon`, `DialogHelper.confirm(icon:)`, ธีม dialog + ปฏิทินพื้นขาว (เดิมย้อมสีพีชตามสีส้ม) ฉากหลังมืดขึ้น, ใส่ไอคอนให้ฟอร์มสินค้า / สต็อก / รายรับ-รายจ่าย / ช่องข้อมูล / ต้นทุน / รายการที่ใช้บ่อย, กล่องยืนยันยกเลิกใบกำกับ / ลบ key AI มีไอคอนของตัวเอง, กล่อง "ขายแล้ว" ในหน้าขายด่วน, หน้าต่างรายการที่ใช้บ่อยแยกกล่องตามประเภท + จำนวน | analyze ผ่าน, test 449 ผ่าน (เพิ่ม test `AppButton`, `AppDialog`, `FormDialog`, `DialogHelper`) — ลองใน Chrome 1280 / 375 กับ API + DB ทดสอบ: ฟอร์มสินค้า, ยืนยันลบสินค้า, รับเข้า, รายจ่าย, รายการที่ใช้บ่อย, ยกเลิกใบกำกับ, ขายแล้ว ✓ | ยังไม่ได้แก้: ปุ่มเลือก รายรับ / รายจ่าย ในฟอร์มชิดหัวข้อ "หมวด" นิดหน่อย |
| 2026-11-01 | **จัดการรายการต้นทุนที่ใช้บ่อย** (ผู้ใช้ขอหลังใส่ชุดต้นทุนร้าน 3D print): `CostPresetsDialog` มีปุ่ม "เพิ่มรายการ" + ปุ่มแก้ / ลบทุกแถว (ลบถามยืนยันก่อน) แยกกลุ่ม วัตถุดิบ / ค่าแรง / ค่าใช้จ่ายอื่น + แถบเลื่อนขึ้นตลอด, `CostItemDialog` เพิ่มโหมด `forPreset` (ไม่มีช่องจำนวน / ช่องเลือกจากรายการ / ติ๊กจำ), `CostRepository.savePreset` ไม่มี id = POST มี id = PUT, `CostPresetModel.fromItem(id:)`, state `presetErrorCode` (เดิม error ของรายการที่ใช้บ่อยไม่ขึ้นที่ไหนเลย), หน้าคำนวณต้นทุนตอนยังไม่มีสินค้าก็มีปุ่มรายการที่ใช้บ่อย, key ภาษา th / en 581 คำ | analyze ผ่าน, test 433 ผ่าน — ลองใน Chrome 1280 กับ API + DB ทดสอบ: เปิดตอนไม่มีสินค้า ✓, แก้ราคา 5 → 6 ✓, ลบ (ถามยืนยัน) ✓, เพิ่มเรซิน 1.20 บาท/กรัม ✓ (เช็คใน API แล้วตรง), ฟอร์มเพิ่มบรรทัดต้นทุนแบบเดิมยังมีช่องจำนวน + ติ๊กจำ ✓ — เจอแล้วแก้: 11 รายการล้นหน้าต่าง 2 รายการสุดท้ายมองไม่เห็นและไม่มีอะไรบอกว่าต้องเลื่อน → ใส่แถบเลื่อนที่ขึ้นตลอด | ไม่ต้องแก้ API (`PUT /cost-presets/{id}` มีอยู่แล้ว) / ร้านยังไม่ได้ตั้ง AI (`.env` ไม่มี `GEMINI_API_KEY`) |
| 2026-10-31 | **แชท AI แบบลอยทุกหน้า + ใส่ key AI ในตั้งค่า + AI ฟรีเป็นค่าเริ่มต้น** (ผู้ใช้ขอแบบแชท Facebook, เลือก Gemini ฟรี): widget ใหม่ `ChatLauncher` (ปุ่มมุมขวาล่าง / หน้าต่าง 400 × 620 บนจอใหญ่ / เต็มจอบนมือถือ, อยู่ใน `AppShell` → ทุกหน้ายกเว้น login) + `ChatPanel` (หัวสีเข้ม บอก AI ที่ใช้, ปุ่มเริ่มแชทใหม่ / ย่อ, คำถามตัวอย่าง, การ์ดงานที่ AI เสนอ), `AssistantBloc` เพิ่ม event `PanelOpened` / `PanelClosed` / `KeySaved` / `KeyRemoved` + state `isOpen` / `hasUnread` / `keyStatus`, model `AiStatusModel`, `AiRepository.getStatus` / `saveKey` / `removeKey`, `AiKeySection` ในหน้าตั้งค่า, `MarketBloc` ใช้ `webSearch` (state `aiEnabled` → `canCheck`), `AiAskCard` บนหน้าภาพรวมเปิดหน้าต่างแชทแทนการเปลี่ยนหน้า, `PageContent` เว้นที่ด้านล่างให้ปุ่มแชท (`AppSizes.chatLauncherSpace`), ลบหน้า `/assistant` + เมนู "ผู้ช่วย AI", key ภาษา th / en 575 คำ | analyze ผ่าน, test 427 ผ่าน — ลองใน Chrome 1280 / 375 กับ API ทดสอบ + พร็อกซี AI ปลอม: ปุ่มแชทขึ้นทุกหน้า ไม่ขึ้นหน้า login ✓, กดคำถามตัวอย่างแล้วได้คำตอบ ✓, มือถือเปิดเต็มจอ / ย่อกลับ ✓, ตั้งค่า: key ผิดรูปแบบขึ้นข้อความเตือน ✓ / บันทึกแล้วเปลี่ยนเป็น "Claude (key ของร้าน …a1B2)" + ช่องล้าง ✓ / ลบ key แล้วกลับเป็น Gemini ฟรี ✓, หน้าเช็คราคาตลาดตอนใช้ AI ฟรี ปุ่มเช็คถูกปิด + ขึ้นคำแนะนำ ✓ — เจอแล้วแก้: วงกลม AI ที่หัวแชทมีเงาเป็นคราบเทา → เอาเงาออก | **ต้องรัน API ใหม่ (`make run`)** + migration `000009` (รันแล้ว) / แชทหายเมื่อรีเฟรชหน้าเว็บ (ไม่ได้เก็บ) |
| 2026-10-31 | **(จาก api-Costbook) AI ฟรี + key ของร้าน:** migration `000009_ai_key` (รันใน DB `costbook` แล้ว), เส้นใหม่ `PUT` / `DELETE /ai/key`, `GET /ai/status` มี field ใหม่ (provider, model, source, web_search, has_own_key, key_hint, free_available), error ใหม่ `ai_key_format_invalid`, `ai_quota_exceeded`, `ai_search_unavailable`, `.env` ใหม่ `GEMINI_API_KEY` / `GEMINI_MODEL` — รายละเอียด `../api-Costbook/docs/ARCHITECTURE.md` | ใช้แล้ว (บรรทัดบน) |
| 2026-10-31 | **หน้าภาพรวมแบบใหม่ตามตัวอย่างที่ผู้ใช้ส่งมา**: widget ใหม่ `KpiCard`, `DeltaPill`, `DashboardPanel`, `SalesTrendChart` (ยอดสะสม เดือนนี้ vs เดือนก่อน), `WeekdayChart`, `CategorySplit`, `TopProductsTable`, `MarginGauge`, `AiAskCard` (พิมพ์ถามบนหน้าภาพรวม → ส่งเข้า `AssistantBloc` แล้วไปหน้าแชท), `ChartUtil.cumulative`, model เพิ่ม `bills` / `grossProfit` / `previousDailySales` / `weekdaySales` / `topCategories`, ปุ่มขายด่วน + ออกเอกสารย้ายไปมุมขวาบน, ลบ `ChangeBadge` / `DailySalesChart` / `StatCard.footer` ที่ไม่ได้ใช้แล้ว + key ภาษาที่ไม่ใช้ | analyze ผ่าน, test 418 ผ่าน — test หน้าภาพรวมเจอแถวสินค้าใกล้หมดล้นจอมือถือ 29 px → แก้แล้ว — ลองใน Chrome 1440 / 375: ชี้ที่เส้นขึ้นตัวเลขทั้ง 2 เดือน ✓, พิมพ์ถาม AI บนหน้าภาพรวมแล้วไปหน้าแชทพร้อมคำตอบ ✓ — ปรับระหว่างทาง: เส้นยอดรายวันแหลม ๆ (มีวันที่ยอด 0 เยอะ) → เปลี่ยนเป็นยอดสะสม, กล่องซ้าย-ขวาสูงไม่เท่ากัน → ย้ายรายจ่ายตามหมวดมาไว้ใต้สินค้าขายดี | ต้องรัน API ใหม่ (`make run`) เพราะมี field ใหม่ |
| 2026-10-31 | **ภาพรวมแบบละเอียด + AI**: เพิ่ม package `fl_chart` 1.3.0 (ผู้ใช้อนุญาต), model ใหม่ `dashboard_sales_model` (ยอดขาย / เดือน / รายวัน / ขายดี / หมวด / สต็อก / ตำแหน่งราคาตลาด), `MarketCheckModel`, `AiActionModel`, `ChatMessageModel`, utils `PercentUtil` / `MarketUtil` / `ChartUtil` + `MoneyUtil.formatShort` + `DateUtil.shortMonthLabel`, widget กลาง `ChangeBadge`, `ChartLegend`, `RankedBarList`, `MarketRangeBar`, `StatCard.footer`, `StatGrid.minCardWidth`, หน้าภาพรวมใหม่ (กราฟ fl_chart 2 ตัว), feature `market` (`MarketBloc` + หน้า `/products/:id/market`), feature `assistant` (`AssistantBloc` ที่ shell + หน้า `/assistant` + การ์ดงาน), `ProductRepository.getProduct`, key ภาษา th / en 535 คำ | analyze ผ่าน, test 413 ผ่าน (util / model / bloc ครบทุกไฟล์) — เลือกสีกราฟด้วยตัวตรวจสี (ผ่านทุกข้อ เตือนสีเขียวอมฟ้าตัดกับพื้นน้อย → ใส่ตารางตัวเลขใต้กราฟ) — ลองใน Chrome 1280 / 375 กับ API ทดสอบ + พร็อกซี AI ปลอม: ภาพรวมครบทุกส่วน (ชี้แท่งแล้วขึ้นตัวเลข), หน้าเช็คตลาด + กดเช็คใหม่, แชท → AI เสนอรับเข้า + แก้ราคา → กดยืนยัน → สต็อก 18 → 28 และราคา 250 → 269 ใน DB จริง ✓, เปลี่ยนหน้าแล้วแชทยังอยู่ ✓ — เจอแล้วแก้: ตัวเลขแกนกราฟติดลบโดนตัด (-5,00 / 0) → ใช้ K ทั้งแกน, ช่วงราคาในการ์ดโดนตัด (199.00 – 39…) → ไม่แสดง .00 ของเลขกลม, ตารางย้อนหลังบนมือถือยาวมาก → พับไว้ | **ต้องรัน API ใหม่ (`make run`)** / AI จะใช้ได้เมื่อใส่ `ANTHROPIC_API_KEY` |
| 2026-10-31 | **(จาก api-Costbook) ภาพรวมแบบละเอียด + AI:** migration `000008` (รันใน DB `costbook` แล้ว), `GET /dashboard` มี field ใหม่ (sales, previous, monthly_trend, daily_sales, top_products, category_sales, expense_by_category, stock, market), เส้นใหม่ `/ai/status`, `/ai/chat`, `/products/{id}/market` (GET / POST), error code ใหม่ `ai_*`, `market_check_not_found` — รายละเอียด `../api-Costbook/docs/ARCHITECTURE.md` | ใช้แล้วในทุกหน้า (บรรทัดบน) |
| 2026-10-31 | **รองรับร้านหลายแบบ**: model ใหม่ `ProductFieldModel`, `CostPresetModel` + field ใหม่ใน Company / Product / CostItem / Movement / Invoice / InvoiceDraft, `TaxUtil.documentAmounts`, `CostUtil.lineAmount` / `percentOf`, `SettingsBloc` ไว้ที่ shell (เมนูตามรูปแบบร้าน), หน้าใหม่ **ขายด่วน** `/sell` + `SellProductTile`, หน้าตั้งค่า (รูปแบบร้าน + ช่องข้อมูลเพิ่มเติม + `ProductFieldDialog`), ฟอร์มสินค้า (`CustomFieldInput`), หน้าต้นทุน (`CostItemDialog` แบบ จำนวน × ราคา / %, `CostPresetsDialog`, กำไรตามรูปแบบ VAT), รับเข้าใส่ทุน + ผู้ขาย, ฟอร์ม / กระดาษ / รายการเอกสาร รองรับใบเสร็จ + ส่วนลด, เมนู "ใบกำกับภาษี" → "เอกสารขาย", key ภาษา th / en 373 คำ | analyze ผ่าน, test 338 ผ่าน (util / model / bloc ครบทุกไฟล์) — ลองใน Chrome กับ API ทดสอบ (`costbook_e2e`) ทั้งร้านจด VAT (ราคารวม VAT + ส่วนลด: 1,500 − 50 = 1,450 ก่อน VAT 1,355.14 VAT 94.86 ✓) และร้านไม่จด VAT (สแกนรหัส → รับเงิน → ได้ใบเสร็จ `RC-2026-0001` → ขายบิลต่อไป สต็อกโหลดใหม่ ✓, งานบริการไม่ตัดสต็อก ✓) ที่ 1280 และ 375 — เจอแล้วแก้: หน้าต้นทุนเขียน "ก่อน VAT" ทั้งที่ร้านตั้งราคารวม VAT, บิลขึ้น "คงเหลือ 0" ของงานบริการ, ใบเสร็จเซ็นชื่อ "ผู้ออกใบกำกับ" → "ผู้รับเงิน", ช่องสินค้าในหน้าขายด่วนบนมือถือเรียงแถวละช่องเดียว / **ต้องรัน API ใหม่ (`make run`)** เพราะ API เปลี่ยน |
| 2026-10-31 | **(จาก api-Costbook) รองรับร้านหลายแบบ:** migration `000007` (รันใน DB `costbook` แล้ว), `/product-fields`, `/cost-presets`, field ใหม่ใน company / products / product_costs / stock_movements / invoices, ใบเสร็จ `RC-`, `items[].amount` ในใบต้นทุนเลิกรับ (ใช้ `kind` + `quantity` × `unit_price` / `percent`) — รายละเอียด `../api-Costbook/docs/ARCHITECTURE.md` | ใช้แล้วในทุกหน้า (บรรทัดบน) |
| 2026-10-31 | ข้อความ "ยังไม่มีข้อมูล" / กำลังโหลด / error อยู่กลางพื้นที่ที่เหลือของจอ (เดิมชิดบนใต้แถบเครื่องมือ): `PageContent` เปลี่ยนจาก `ListView` เป็น `CustomScrollView` + `centerChild` (`SliverFillRemaining`), `EmptyView` / `ErrorView` จัดตัวเองไว้กลาง, หน้า สินค้า / สต็อก / รายรับ-รายจ่าย / ใบกำกับ / ภาพรวม แยก `_stateView` ออกมาส่งเข้า `centerChild` + test `page_content_test` (3) | analyze ผ่าน, test 278 ผ่าน, ดูภาพจริงใน Chrome 1280 / 375 กับ DB `costbook` (ยังไม่มีสินค้า) แล้ว |
| 2026-10-31 | **ทำหน้าจริงทุกเมนู + ต่อ API**: package intl / pdf / printing, `ApiClient` get / put / delete + 401, utils (Money / Tax / Cost / Date / Error), helpers (Dialog / Snackbar / Pdf), widget กลาง 13 ตัว, `LanguageBloc`, feature dashboard / product / cost / stock / transaction / invoice (list / form / detail + กระดาษใบกำกับ A4) / settings แต่ละตัวมี model + repository + bloc + หน้า + test, route `/invoices/create` และ `/invoices/:id`, key ภาษา th / en 272 คำ, ลบ `ComingSoonView` | analyze ผ่าน, test 275 ผ่าน (util / model / bloc ครบทุกไฟล์), build web ผ่าน — ลองกับ API จริง (DB ทดสอบ `costbook_e2e`) ใน Chrome ทุกหน้าที่ 1280 และบางหน้าที่ 375 แล้ว ไม่มี error ใน console, กดดาวน์โหลด PDF ได้ไฟล์ A4 ภาษาไทยถูก — package `pdf` วางวรรณยุกต์ไทยผิด ("ที่อยู่" → "ทีอยู่") จึงสร้าง PDF จากรูปของหน้าจอแทน (เลือกตัวหนังสือใน PDF ไม่ได้) / test ระดับหน้าเจอแถวสินค้าใกล้หมดล้นจอมือถือ → แก้แล้ว / ยังไม่ได้ลองกดฟอร์มทุกปุ่มใน Chrome (logic ทดสอบใน bloc test แล้ว) |
| 2026-10-31 | **(จาก api-Costbook) API ทุกเมนูพร้อมใช้:** product, cost (`GET` / `PUT /products/{id}/costs` ส่งทั้งใบ), stock (`/stock`, `/stock/movements`, `/stock/in`, `/stock/out`), transaction (`?month=2026-10` + `/summary`), invoice (`?month=`, `POST /invoices`, `/invoices/{id}`, `/invoices/{id}/cancel`), dashboard — ต้อง login ทุกเส้น, error code ใหม่ดู `../api-Costbook/docs/ARCHITECTURE.md` หัวข้อ 6 หรือ `http://localhost:8080/docs` | ใช้แล้วในทุกหน้า (บรรทัดบน) |
| 2026-10-31 | ปุ่ม ☰ หด / กางเมนูข้างบนจอคอมแบบ smooth (`AnimatedContainer` 250ms): หดเหลือแถบไอคอน 76px + tooltip ชื่อเมนู, ไอคอนปุ่มสลับ ☰ / เมนูเปิด แบบจาง, มือถือ-แท็บเล็ตใช้ปุ่ม ☰ เปิด Drawer (มี tooltip `common.toggle_menu`) | test 114 ผ่าน (มี test ระหว่าง animation ไม่ล้นจอ), ดูภาพจริงใน Chrome ทั้งตอนกางและหดแล้ว |
| 2026-10-31 | เมนูข้าง (sidebar) 7 หน้า: `AppMenu` + `AppShell` + `PageLayout` + `AppSideMenu` ใน `ShellRoute`, จอคอมเมนูอยู่ซ้ายตลอด / มือถือ-แท็บเล็ตเป็น Drawer (☰), ปุ่มออกจากระบบย้ายไปล่างสุดของเมนู, แยก `ShopLogo` เป็น widget กลาง (ใช้ทั้ง login และเมนู), หน้าที่ยังไม่ได้ทำใช้ `ComingSoonView`, เพิ่ม `appBarTheme` | test 109 ผ่าน, ดูภาพจริงใน Chrome 375 (ปิด / เปิดเมนู) / 768 / 1440 แล้ว |
| 2026-10-31 | แอนิเมชันเปลี่ยนหน้าแบบซูมแทนการเลื่อน: `AppPageTransition.forward` (หน้าทั่วไป: ขยายเข้า / หดออก) และ `.backward` (หน้า login: ย่อเข้า / ขยายออก) ใช้ผ่าน `pageBuilder` ใน `appRouter` + `ColoredBox` พื้นหลังใน `app.dart` | test 88 ผ่าน (มี test ยืนยันว่า `go` แล้วหน้าเก่าซูมออกจริง), อัดเฟรมตอน logout ใน Chrome แล้ว (เครื่องทดสอบเรนเดอร์ช้า เห็นแค่บางเฟรม) |
| 2026-10-31 | ออกจากระบบแล้วหน้า login แสดงอีเมลเดิม: `AuthRepository` เก็บอีเมลล่าสุด (`last_email`) ทุกครั้งที่ login สำเร็จ, logout ลบแค่ token, เพิ่ม event `SavedEmailRequested` + `AuthState.savedEmail`, หน้า login ขออีเมลตอนเปิดแล้วใส่ช่องอีเมล (ถ้ายังว่าง) | เก็บอีเมลเสมอไม่ขึ้นกับติ๊กจดจำ, test 80 ผ่าน |
| 2026-10-31 | โลโก้ร้านจาก API: เพิ่ม `ApiConstants.companyLogoUrl`, หน้า login แสดงโลโก้ (`Image.network` ในกรอบขาวมุมโค้ง 96 px เหนือชื่อแอป แทนไอคอนส้มเดิม — โหลดไม่ได้แสดงไอคอน CostBook ขนาดเดียวกัน), favicon ใน `web/index.html` ชี้ไปที่ `http://localhost:8080/api/v1/company/logo` (ไม่เพิ่ม package), `AppSizes.logoSize` + test (`api_constants_test` 2, login_page เพิ่ม 2) | analyze ผ่าน, test 72 ผ่าน, build web ผ่าน, ดูภาพจริงใน Chrome 375x667 / 1280x800 แล้ว โลโก้ MAKEHUB ขึ้น + favicon โหลดจาก API ได้ 200 — ร้านไม่มีโลโก้ favicon จะเป็นไอคอนว่างของ browser / `apple-touch-icon` และไอคอนใน `manifest.json` ยังเป็นของ Flutter เดิม |
| 2026-10-31 | **ต่อ API login**: เพิ่ม package flutter_bloc, equatable, http, go_router, shared_preferences, bloc_test, mocktail / `ApiConstants`, `AppStatus`, `ApiClient` + `ApiException`, `AuthRepository` (login / logout / loadSavedToken), `AuthBloc` (`LoginSubmitted`, `LogoutRequested`), `AppRoutes` + `appRouter` (redirect: ไม่มี token → `/login`), `DashboardPage` (หน้าแรกเปล่า + ปุ่มออกจากระบบ), `AppButton.isLoading`, หน้า login แสดง error `'error.<code>'.tr` + ปุ่มหมุนตอนรอ, key ภาษา `common.logout`, `dashboard.welcome`, `error.*` (invalid_credentials, email_required, password_required, server_error, network_error, unknown_error) | analyze ผ่าน, test 68 ผ่าน (เพิ่ม api_client 8, auth_repository 6, auth_bloc 4, login_page 6, dashboard_page 2), `flutter build web` ผ่าน, ลองเรียก API จริงด้วย `ApiClient`: รหัสถูกได้ token / รหัสผิด + ไม่มีอีเมลได้ `invalid_credentials`, CORS preflight 204 — **ยังไม่ได้ดูภาพจริงใน Chrome** / ยังไม่จัดการ token หมดอายุ (`error.unauthorized` ยังไม่เพิ่ม) |
| 2026-10-31 | **(จาก api-Costbook) API ข้อมูลร้าน + โลโก้ พร้อมใช้** (1 ระบบ = 1 ร้าน แก้ข้อมูลร้านผ่าน API หน้าเว็บไม่ต้องแก้): `GET /api/v1/company` → `{"name","address","tax_id","branch","phone","has_logo"}` (ไม่ต้อง login) / `PUT /api/v1/company` (ต้อง login) ส่งครบทุกช่อง → 400 `company_name_required`, `company_tax_id_invalid` / `GET /api/v1/company/logo` → รูปตรง ๆ ใช้ `Image.network` ได้ (ไม่ต้อง login) 404 `logo_not_found` = แสดงโลโก้ CostBook แทน / `PUT /api/v1/company/logo` multipart ช่อง `logo` PNG / JPG / WebP ≤ 1 MB → 400 `logo_required`, `logo_too_large`, `logo_type_invalid` / `DELETE /api/v1/company/logo` → 204 | ยังไม่ได้แก้โค้ด Flutter — ใช้ในหน้า settings + หน้า login + PDF ใบกำกับ, เพิ่ม key `error.<code>` ข้างบนใน `th.json` / `en.json`, หลังอัปโหลดโลโก้ใหม่ต้องล้าง cache รูป (`imageCache` / ใส่ key ใหม่) — รายละเอียด: `../api-Costbook/docs/ARCHITECTURE.md` หัวข้อ 7 หรือ `http://localhost:8080/docs` |
| 2026-10-31 | ปิดแถบ DEBUG มุมขวาบน (`debugShowCheckedModeBanner: false` ใน `app.dart`) | |
| 2026-10-31 | กลับไปใช้พื้นหลังแบบแบ่งบน-ล่าง แล้วตกแต่งครึ่งบน: ไล่สีเทาเข้ม, ขอบล่างโค้ง, แถบเฉียงสีส้มมุมขวาบน (ตำแหน่งตามสัดส่วนจอ ไม่ทับตัวหนังสือบนมือถือ), แสงส้มมุมขวาบน / ซ้ายล่าง, ลายจุดจาง ๆ | ผู้ใช้ชอบแบบแบ่ง แค่อยากให้ครึ่งบนสวยขึ้น, test 42 ผ่าน, ดูภาพจริงใน Chrome 375 / 768 / 1072x1782 / 1440 / 2560 แล้ว |
| 2026-10-31 | พื้นหลังหน้า login ใหม่: เทาเข้มเต็มจอ + แสงส้มมุมซ้ายบน / ขวาล่าง + ลายจุดจาง ๆ แยกเป็น `LoginBackground` (features/auth/widgets) แทนแบบแบ่งครึ่งบน-ล่าง | test 42 ผ่าน, ดูภาพจริงใน Chrome 375 / 768 / 1072x1782 / 1440 / 2560 แล้ว |
| 2026-10-31 | ออกแบบหน้า login ใหม่ทั้งหมด: เอาแถบรูปด้านข้าง + โลโก้ / รูป MakeHub ออก, ใช้หน้าเดียวทุกขนาดจอ (ครึ่งบนเทาเข้ม + แสงส้ม, ชื่อแอป CostBook, การ์ดฟอร์มกลางจอ), ชื่อช่องอยู่เหนือช่องกรอก + ตัวอย่างในช่อง, Enter ไปช่องถัดไป, autofill รหัสผ่าน, ปุ่มส้มตัวหนังสือเข้ม (อ่านชัด) | โลโก้ขึ้นกับแต่ละร้าน → ย้ายไปทำในหน้า settings, ลบ `assets/images/*` + `AppImages`, test 42 ผ่าน, ดูภาพจริงใน Chrome 320–2560 แล้ว |
| 2026-10-31 | **(จาก api-Costbook) API login พร้อมใช้:** `POST /api/v1/auth/login` ส่ง `{"email","password"}` → 200 `{"token","user":{"id","email","first_name","last_name"}}` / 400 `invalid_json`, `email_required`, `password_required` / 401 `invalid_credentials` — `GET /api/v1/auth/me` ส่ง header `Authorization: Bearer <token>` → 200 user / 401 `unauthorized` (ให้ลบ token แล้วไปหน้า login) — token อายุ 7 วัน, ผู้ใช้ทดสอบ `admin@costbook.com` / `1234` | ยังไม่ได้แก้โค้ด Flutter — ต้องเพิ่ม key `error.invalid_credentials`, `error.email_required`, `error.password_required`, `error.unauthorized` ใน `th.json` / `en.json` ตอนต่อ API — รายละเอียด: `../api-Costbook/docs/ARCHITECTURE.md` หัวข้อ 7 |
| 2026-10-31 | หน้า login จอคอม: เพิ่มโลโก้ด้านบนฟอร์ม (รวมเป็น `_logoAndForm` ใช้ร่วมกับการ์ดของแท็บเล็ต) + test โลโก้ทุกขนาดจอ | test 45 ผ่าน, ดูภาพจริงที่ 1100 และ 1440 แล้ว |
| 2026-10-31 | ออกแบบหน้า login ใหม่ด้วยโลโก้และสีของ MakeHub (ส้ม `#FD7402` + เทาเข้ม `#1B2228`) + checkbox จดจำการเข้าสู่ระบบ, เพิ่ม `assets/images/` (logo.png, logo_light.png, login_photo.jpg) + `AppImages` | โลโก้พื้นใส 2 แบบทำจากไฟล์ที่ผู้ใช้ส่งมา ตัดบรรทัดหมวดหมู่ออก (แสดงเป็นข้อความแทน), รูปพื้นหลังตัดจากแบนเนอร์ส่วนที่ไม่มีตัวหนังสือ, ดูภาพจริงใน Chrome ทุกขนาด, test 42 ผ่าน |
| 2026-10-31 | หน้า login (UI): `LoginPage` + `_ext.dart`, ระบบภาษา `AppLang` + `.tr` + `th.json` / `en.json`, `ValidatorUtil`, atoms `AppButton` / `AppTextField`, theme ปุ่ม / ช่องกรอก / การ์ด + test | มือถือ = ฟอร์มเต็มจอ, แท็บเล็ต = การ์ดกลางจอ, จอคอม = แถบแบรนด์ซ้าย + การ์ด, จอใหญ่ = ขยายตามสัดส่วน — ดูภาพจริงใน Chrome ที่ 320 / 375 / 768 / 1280 / 1440 / 2560 แล้ว, test 39 ผ่าน |
| 2026-10-31 | ลบคอมเมนต์ทั้งหมดในโค้ด (`lib/`, `test/`, `pubspec.yaml`) และเปลี่ยนกฎใน skill `simple-code` เป็น "ไม่เขียนคอมเมนต์ในโค้ด" | ยกเว้น `// TODO: ต่อ API` ใน repository |
| 2026-10-31 | รองรับทุกขนาดจอ: breakpoint mobile < 600 / tablet < 1024 / desktop, จอกว้างกว่า 1440 ขยายทั้งแอปตามสัดส่วนด้วย `ScreenScaler` (สูงสุด 2 เท่า) + กฎใน skill `simple-code` และ `docs/ARCHITECTURE.md` หัวข้อ 8 | ใช้ `fvm flutter` (global flutter 3.29 ทำ `pubspec.lock` ถอยเวอร์ชัน), analyze / test 18 ผ่าน |
| 2026-10-31 | `flutter create` + สร้างโฟลเดอร์ตาม `docs/ARCHITECTURE.md`, เพิ่มฟอนต์ LINESeedSansTH (5 น้ำหนัก) และ theme ใน `lib/core/theme/` (`AppColors`, `AppSizes`, `AppTheme`) + test | ย้าย `app_colors` / `app_sizes` จาก `constants/` ไป `theme/`, ลบ test counter ของ flutter create, analyze / test / build web ผ่าน |
| 2026-10-31 | เพิ่มวิธีต่อ API ใน `docs/ARCHITECTURE.md` (baseUrl หัวข้อ 1, error code → `.tr` หัวข้อ 10) | ตามกติกาของ `../api-Costbook` |
| 2026-10-31 | เพิ่มกฎ "หน้าโค้ดเยอะ → แยกส่วนย่อยเป็น extension ในไฟล์ `<ชื่อหน้า>_ext.dart`" ใน skill `simple-code` และ `docs/ARCHITECTURE.md` (หัวข้อ 3, 8, 13) | แก้แค่เอกสาร ทดลองแบบ `part` + extension ในโปรเจกต์ชั่วคราวแล้ว analyze ผ่าน |
| 2026-10-31 | เพิ่มกฎ "โค้ดที่ใช้ตั้งแต่ 2 จุด → แยกเป็นฟังก์ชันกลาง" ใน skill `simple-code` และ `docs/ARCHITECTURE.md` หัวข้อ 9 | แก้แค่เอกสาร ไม่มีโค้ด Dart |
| 2026-10-31 | สร้าง `docs/ARCHITECTURE.md`, `CLAUDE.md`, `PROGRESS.md`, skill `simple-code` และ `unit-test-check` | ยังไม่มีโค้ด Flutter |
