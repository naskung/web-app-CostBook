import 'package:flutter/material.dart';

// ช่องค้นหา
// value = คำค้นจาก state (ถ้าเปลี่ยนจากที่อื่น เช่น สแกนบาร์โค้ด ช่องจะแสดงตาม) / suffix = ปุ่มท้ายช่อง เช่น ปุ่มสแกน
class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.hint, required this.onChanged, this.value, this.suffix});

  final String hint;
  final ValueChanged<String> onChanged;
  final String? value;
  final Widget? suffix;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _controller = TextEditingController(text: widget.value ?? '');

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = widget.value;
    if (value != null && value != _controller.text) _controller.text = value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.suffix,
      ),
    );
  }
}
