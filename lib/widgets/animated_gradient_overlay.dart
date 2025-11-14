/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color darken([double amount = 0.2]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

class AnimatedGradientOverlay extends StatefulWidget {
  final WallpaperService wallpaperService;

  const AnimatedGradientOverlay({
    super.key,
    required this.wallpaperService,
  });

  @override
  State<AnimatedGradientOverlay> createState() => _AnimatedGradientOverlayState();
}

class _AnimatedGradientOverlayState extends State<AnimatedGradientOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Color> _getDarkenedColors() {
    if (widget.wallpaperService.selectedOption == WallpaperOption.gradient) {
      final gradient = widget.wallpaperService.gradient.gradient;
      if (gradient is LinearGradient) {
        return gradient.colors.map((color) => color.darken(0.25)).toList();
      } else if (gradient is RadialGradient) {
        return gradient.colors.map((color) => color.darken(0.25)).toList();
      }
    }

    // Default dark colors for image wallpapers or fallback
    return [
      Colors.black.withOpacity(0.15),
      Colors.black87.withOpacity(0.1),
      Colors.black54.withOpacity(0.12),
    ];
  }

  Gradient _createAnimatedGradient() {
    final colors = _getDarkenedColors();
    final animationValue = _animation.value;

    if (widget.wallpaperService.selectedOption == WallpaperOption.gradient) {
      final gradient = widget.wallpaperService.gradient.gradient;
      
      if (gradient is LinearGradient) {
        // Animate between different gradient configurations
        final begin = gradient.begin as Alignment;
        final end = gradient.end as Alignment;
        final transform = gradient.transform;

        // Create subtle shift in gradient position
        final shiftedBegin = Alignment.lerp(
          begin,
          Alignment(begin.x + 0.1 * animationValue, begin.y + 0.05 * animationValue),
          animationValue,
        ) ?? begin;

        final shiftedEnd = Alignment.lerp(
          end,
          Alignment(end.x - 0.1 * animationValue, end.y - 0.05 * animationValue),
          animationValue,
        ) ?? end;

        return LinearGradient(
          colors: colors,
          begin: shiftedBegin,
          end: shiftedEnd,
          transform: transform,
          stops: gradient.stops,
        );
      } else if (gradient is RadialGradient) {
        // Animate radius and center for radial gradients
        final center = gradient.center as Alignment;
        final radius = gradient.radius;

        final shiftedCenter = Alignment.lerp(
          center,
          Alignment(
            center.x + 0.05 * animationValue,
            center.y + 0.05 * animationValue,
          ),
          animationValue,
        ) ?? center;

        final animatedRadius = radius + (0.1 * animationValue);

        return RadialGradient(
          colors: colors,
          center: shiftedCenter,
          radius: animatedRadius.clamp(0.5, 1.5),
          stops: gradient.stops,
        );
      }
    }

    // Default animated gradient for image wallpapers
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [
        0.0 + (0.1 * animationValue),
        0.5,
        1.0 - (0.1 * animationValue),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: _createAnimatedGradient(),
            ),
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.05 * _animation.value),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          );
        },
      ),
    );
  }
}