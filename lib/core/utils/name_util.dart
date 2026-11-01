class NameUtil {
  // สระที่เขียนอยู่หน้าพยัญชนะ — ตัวย่อต้องเอาพยัญชนะตัวถัดไปมาด้วย ไม่งั้นเหลือแค่ "เ"
  static const String _leadingVowels = 'เแโใไ';

  // ตัวอักษรย่อในรูปโปรไฟล์ เช่น "สมชาย" → "ส", "เอก" → "เอ", "anna" → "A"
  static String initialOf(String name) {
    final letters = name.trim().runes.map(String.fromCharCode).toList();
    if (letters.isEmpty) return '';
    if (_leadingVowels.contains(letters.first) && letters.length > 1) return letters[0] + letters[1];
    return letters.first.toUpperCase();
  }
}
