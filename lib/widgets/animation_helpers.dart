import 'package:flutter/material.dart';

class PremiumAnimations {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Easing curves
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.easeOutBack;

  // Scale animations
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 1.0,
    double end = 1.05,
    Curve curve = easeOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  // Opacity animations
  static Animation<double> createOpacityAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = easeOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  // Slide animations
  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0, 0.3),
    Offset end = Offset.zero,
    Curve curve = easeOut,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  // Staggered animations for lists
  static Widget createStaggeredAnimation({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = medium,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class MicroInteractionController {
  late final AnimationController _scaleController;
  late final AnimationController _glowController;
  late final AnimationController _bounceController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _bounceAnimation;

  MicroInteractionController(TickerProvider vsync) {
    _scaleController = AnimationController(
      duration: PremiumAnimations.medium,
      vsync: vsync,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    _scaleAnimation = PremiumAnimations.createScaleAnimation(
      _scaleController,
      begin: 1.0,
      end: 1.05,
      curve: PremiumAnimations.spring,
    );

    _glowAnimation = PremiumAnimations.createOpacityAnimation(
      _glowController,
      begin: 0.3,
      end: 0.8,
      curve: Curves.easeInOut,
    );

    _bounceAnimation = PremiumAnimations.createScaleAnimation(
      _bounceController,
      begin: 1.0,
      end: 1.1,
      curve: PremiumAnimations.bounce,
    );
  }

  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<double> get glowAnimation => _glowAnimation;
  Animation<double> get bounceAnimation => _bounceAnimation;

  AnimationController get scaleController => _scaleController;
  AnimationController get glowController => _glowController;
  AnimationController get bounceController => _bounceController;

  void animateFocus() {
    _scaleController.forward();
    _glowController.repeat(reverse: true);
  }

  void animateUnfocus() {
    _scaleController.reverse();
    _glowController.stop();
    _glowController.reset();
  }

  void animateSuccess() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
  }

  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _bounceController.dispose();
  }
}
