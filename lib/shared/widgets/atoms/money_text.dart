import 'package:flutter/material.dart';

import 'package:costbook/core/utils/money_util.dart';

class MoneyText extends StatelessWidget {
  const MoneyText(this.value, {super.key, this.style, this.color, this.prefix = ''});

  final double value;
  final TextStyle? style;
  final Color? color;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    return Text(
      '$prefix${MoneyUtil.format(value)}',
      style: baseStyle?.copyWith(color: color, fontFeatures: const [FontFeature.tabularFigures()]),
    );
  }
}
