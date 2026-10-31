import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPageTransition {
  static const Duration duration = Duration(milliseconds: 400);
  static const double forwardStartScale = 0.9;
  static const double backwardStartScale = 1.1;

  static Page<void> forward({required LocalKey key, required Widget child}) {
    return _zoomPage(key, child, forwardStartScale);
  }

  static Page<void> backward({required LocalKey key, required Widget child}) {
    return _zoomPage(key, child, backwardStartScale);
  }

  static Page<void> _zoomPage(LocalKey key, Widget child, double startScale) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _enter(animation, startScale, _exit(secondaryAnimation, startScale, child));
      },
    );
  }

  static Widget _enter(Animation<double> animation, double startScale, Widget child) {
    final scale = Tween(begin: startScale, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack));
    final opacity = CurveTween(curve: Curves.easeOut);
    return FadeTransition(
      opacity: animation.drive(opacity),
      child: ScaleTransition(scale: animation.drive(scale), child: child),
    );
  }

  static Widget _exit(Animation<double> secondaryAnimation, double startScale, Widget child) {
    final scale = Tween(begin: 1.0, end: startScale).chain(CurveTween(curve: Curves.easeOut));
    final opacity = Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut));
    return FadeTransition(
      opacity: secondaryAnimation.drive(opacity),
      child: ScaleTransition(scale: secondaryAnimation.drive(scale), child: child),
    );
  }
}
