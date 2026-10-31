import 'package:flutter/material.dart';

/// สีทั้งหมดของแอป แก้ที่นี่ที่เดียว ทุกหน้าเปลี่ยนตาม
class AppColors {
  static const Color primary = Color(0xFF2563EB); // สีหลัก: ปุ่ม, เมนูที่เลือก
  static const Color background = Color(0xFFF5F7FA); // พื้นหลังหน้า
  static const Color surface = Color(0xFFFFFFFF); // พื้นการ์ด / ตาราง / ฟอร์ม
  static const Color border = Color(0xFFE2E8F0); // เส้นขอบ / เส้นแบ่ง

  static const Color textPrimary = Color(0xFF1E293B); // ตัวอักษรหลัก
  static const Color textSecondary = Color(0xFF64748B); // ตัวอักษรรอง / คำอธิบาย

  static const Color success = Color(0xFF16A34A); // รายรับ / สำเร็จ
  static const Color danger = Color(0xFFDC2626); // รายจ่าย / error
  static const Color warning = Color(0xFFF59E0B); // สินค้าใกล้หมด
}
