import 'package:flutter/material.dart';

import 'package:costbook/core/utils/responsive_util.dart';

class ScreenScaler extends StatelessWidget {
  const ScreenScaler({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scale = ResponsiveUtil.scaleOf(media.size.width);
    if (scale == 1) return child;

    final scaledMedia = media.copyWith(
      size: media.size / scale,
      padding: media.padding / scale,
      viewPadding: media.viewPadding / scale,
      viewInsets: media.viewInsets / scale,
      devicePixelRatio: media.devicePixelRatio * scale,
    );
    return FittedBox(
      fit: BoxFit.fill,
      alignment: Alignment.topLeft,
      child: SizedBox.fromSize(
        size: scaledMedia.size,
        child: MediaQuery(data: scaledMedia, child: child),
      ),
    );
  }
}
