import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

// กล่องรูปมุมมน: bytes (รูปที่เพิ่งเลือก) มาก่อน url / ไม่มีรูป หรือโหลดไม่ได้ → กล่องเทาพร้อมไอคอน
class AppImageBox extends StatelessWidget {
  const AppImageBox({
    super.key,
    this.url = '',
    this.bytes,
    this.headers = const {},
    this.width,
    this.height,
    this.radius = AppSizes.radiusSmall,
    this.placeholderIcon = Icons.image_outlined,
  });

  final String url;
  final Uint8List? bytes;
  final Map<String, String> headers;
  final double? width;
  final double? height;
  final double radius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: width, height: height, child: _image()),
    );
  }

  Widget _image() {
    final picked = bytes;
    if (picked != null) return Image.memory(picked, fit: BoxFit.cover);
    if (url.isEmpty) return _placeholder();
    return Image.network(
      url,
      headers: headers,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
      frameBuilder: (context, child, frame, wasLoadedSync) => frame == null && !wasLoadedSync ? _placeholder() : child,
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.chartTrack,
      child: Center(child: Icon(placeholderIcon, color: AppColors.textSecondary, size: AppSizes.iconSmall)),
    );
  }
}
