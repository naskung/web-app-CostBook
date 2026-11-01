import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';
import 'package:costbook/core/utils/percent_util.dart';

// การ์ดตัวเลขสรุป: ไอคอน + ชื่อ → ตัวเลขใหญ่ → คำอธิบาย → แถบสัดส่วน (ชิดล่าง แถบทุกใบอยู่ระดับเดียวกัน)
// isHighlighted = การ์ดผลลัพธ์ของหน้า (เช่น กำไรสุทธิ) พื้นเข้ม ตัวเลขใหญ่กว่า มีแถบเฉียงสีที่มุม (แบบหน้า login)
// share = % ที่ใช้วาดแถบ (null = ไม่มีแถบ), shareLabel = ข้อความข้างแถบ, badge = ป้ายท้ายชื่อ (เช่น % เทียบเดือนก่อน)
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.caption,
    this.valueColor,
    this.isHighlighted = false,
    this.share,
    this.shareLabel = '',
    this.badge,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String? caption;
  final Color? valueColor;
  final bool isHighlighted;
  final double? share;
  final String shareLabel;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isHighlighted ? null : AppColors.surface,
        gradient: isHighlighted ? const LinearGradient(colors: [AppColors.dark, AppColors.darkLight]) : null,
        borderRadius: BorderRadius.circular(AppSizes.panelRadius),
        border: Border.all(color: isHighlighted ? AppColors.dark : AppColors.border),
      ),
      child: CustomPaint(
        painter: isHighlighted ? _CornerStripesPainter(color) : null,
        child: Padding(padding: const EdgeInsets.all(AppSizes.panelPadding), child: _content(context)),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final caption = this.caption;
    final share = this.share;
    final badge = this.badge;
    final secondary = isHighlighted ? AppColors.onDarkSecondary : AppColors.textSecondary;
    final mainColor = valueColor ?? (isHighlighted ? AppColors.onDark : AppColors.textPrimary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _iconChip(),
            const SizedBox(width: AppSizes.statIconGap),
            Expanded(
              child: Text(
                label,
                style: textTheme.titleSmall?.copyWith(color: secondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null) ...[const SizedBox(width: AppSizes.spaceSmall), badge],
          ],
        ),
        const SizedBox(height: AppSizes.spaceMedium),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: isHighlighted ? AppSizes.statHeroFont : AppSizes.kpiFont,
              color: mainColor,
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: AppSizes.spaceXSmall),
          Text(
            caption,
            style: textTheme.bodySmall?.copyWith(color: secondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (share != null) ...[const Spacer(), const SizedBox(height: AppSizes.spaceMedium), _meter(context, share)],
      ],
    );
  }

  Widget _iconChip() {
    return Container(
      width: AppSizes.statIconBox,
      height: AppSizes.statIconBox,
      decoration: BoxDecoration(
        color: isHighlighted ? color : backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Icon(icon, color: isHighlighted ? AppColors.onPrimary : color, size: AppSizes.iconSmall),
    );
  }

  Widget _meter(BuildContext context, double share) {
    final textColor = isHighlighted ? AppColors.onDark : AppColors.textPrimary;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.statMeterHeight),
            child: LinearProgressIndicator(
              value: PercentUtil.fraction(share),
              minHeight: AppSizes.statMeterHeight,
              color: color,
              backgroundColor: isHighlighted ? AppColors.trackOnDark : backgroundColor,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spaceSmall),
        Text(
          shareLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// แถบเฉียง 2 เส้น (หนา + บาง) ที่มุมขวาบน วิ่งออกขอบขวาก่อนถึงตัวหนังสือ
class _CornerStripesPainter extends CustomPainter {
  const _CornerStripesPainter(this.color);

  final Color color;

  static const double _thinAlpha = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    final thickStart = size.width - AppSizes.statStripeStart;
    final thinStart = thickStart + AppSizes.statStripeWidth + AppSizes.statStripeGap;
    _drawStripe(canvas, thickStart, AppSizes.statStripeWidth, color);
    _drawStripe(canvas, thinStart, AppSizes.statStripeThinWidth, color.withValues(alpha: _thinAlpha));
  }

  void _drawStripe(Canvas canvas, double startX, double width, Color color) {
    final path =
        Path()
          ..moveTo(startX, 0)
          ..lineTo(startX + width, 0)
          ..lineTo(startX + width + AppSizes.statStripeLength, AppSizes.statStripeLength)
          ..lineTo(startX + AppSizes.statStripeLength, AppSizes.statStripeLength)
          ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CornerStripesPainter oldDelegate) => oldDelegate.color != color;
}
