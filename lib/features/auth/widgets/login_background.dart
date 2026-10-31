import 'package:flutter/material.dart';

import 'package:costbook/core/theme/app_colors.dart';
import 'package:costbook/core/theme/app_sizes.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.background,
      child: FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: AppSizes.loginBandRatio,
        child: ClipPath(
          clipper: _CurveClipper(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.dark, AppColors.darkLight],
                  ),
                ),
              ),
              _Glow(center: Alignment.topRight, radius: 1, color: AppColors.glow),
              _Glow(center: Alignment.bottomLeft, radius: 0.8, color: AppColors.glowSoft),
              CustomPaint(painter: _DotPainter()),
              CustomPaint(painter: _StripePainter()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.center, required this.radius, required this.color});

  final Alignment center;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: radius,
          colors: [color, AppColors.glowEnd],
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  const _DotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.dot;
    for (var x = AppSizes.dotSpacing; x < size.width; x += AppSizes.dotSpacing) {
      for (var y = AppSizes.dotSpacing; y < size.height; y += AppSizes.dotSpacing) {
        canvas.drawCircle(Offset(x, y), AppSizes.dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) => false;
}

class _StripePainter extends CustomPainter {
  const _StripePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final thickStart = size.width * AppSizes.stripeStartRatio;
    final thinStart = thickStart + AppSizes.stripeWidth + AppSizes.stripeGap;
    _drawStripe(canvas, thickStart, AppSizes.stripeWidth, AppColors.primary);
    _drawStripe(canvas, thinStart, AppSizes.stripeThinWidth, AppColors.stripeSoft);
  }

  void _drawStripe(Canvas canvas, double startX, double width, Color color) {
    final path = Path()
      ..moveTo(startX, 0)
      ..lineTo(startX + width, 0)
      ..lineTo(startX + width + AppSizes.stripeSlant, AppSizes.stripeLength)
      ..lineTo(startX + AppSizes.stripeSlant, AppSizes.stripeLength)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StripePainter oldDelegate) => false;
}

class _CurveClipper extends CustomClipper<Path> {
  const _CurveClipper();

  @override
  Path getClip(Size size) {
    final edgeY = size.height - AppSizes.curveDepth;
    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, edgeY)
      ..quadraticBezierTo(size.width / 2, size.height + AppSizes.curveDepth, 0, edgeY)
      ..close();
  }

  @override
  bool shouldReclip(_CurveClipper oldClipper) => false;
}
