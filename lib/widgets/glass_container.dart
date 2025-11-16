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

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/settings_service.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool enableBlur; // Allow disabling blur for nested containers

  const GlassContainer({
    Key? key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.border,
    this.boxShadow,
    this.gradient,
    this.enableBlur = true, // Default enabled
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check performance settings
    final settings = context.watch<SettingsService>();
    final useBlur = enableBlur && settings.glassEffectsEnabled;
    final effectiveBlur = settings.highQualityEffects ? blur : blur * 0.6;
    
    return RepaintBoundary( // Cache this expensive widget
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: border ?? _defaultBorder(context),
            boxShadow: boxShadow ?? _defaultShadow(context),
          ),
          child: Stack(
            children: [
              // Background blur layer - ONLY if enabled
              if (useBlur)
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: effectiveBlur, 
                    sigmaY: effectiveBlur,
                    tileMode: TileMode.clamp, // Prevent edge artifacts
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      color: Theme.of(context).colorScheme.background.withValues(alpha: opacity),
                      gradient: gradient ?? _defaultGradient(context),
                    ),
                  ),
                )
              else
                // Solid fallback when blur disabled
                Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: Theme.of(context).colorScheme.background.withValues(alpha: 0.90),
                    gradient: gradient ?? _defaultGradient(context),
                  ),
                ),
              // Content
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Border _defaultBorder(BuildContext context) {
    return Border.all(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      width: 1.0,
    );
  }

  List<BoxShadow> _defaultShadow(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  LinearGradient _defaultGradient(BuildContext context) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.02),
        Colors.transparent,
      ],
    );
  }
}
