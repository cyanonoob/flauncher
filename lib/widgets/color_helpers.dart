import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

Color computeBorderColor(double tick, Color defaultColor) {
  assert(tick >= 0.0 && tick <= 1.0, 'Tick must be between 0.0 and 1.0');
  
  if (tick == 1.0) {
    return defaultColor;
  }
  
  // Create a border color based on the tick value
  // This modifies the default color by adjusting its lightness/brightness
  final hslColor = HSLColor.fromColor(defaultColor);
  
  // Vary the lightness based on tick - darker for lower values, lighter for higher
  final lightnessFactor = 0.3 + (tick * 0.4); // Range from 0.3 to 0.7
  final newLightness = hslColor.lightness * lightnessFactor;
  
  return hslColor.withLightness(newLightness.clamp(0.0, 1.0)).toColor();
}

Color resolvePanelSurfaceColor(ColorScheme colorScheme) {
  final Color primarySurface = colorScheme.surfaceContainerHigh;
  if (primarySurface.alpha != 0) {
    return primarySurface;
  }

  final Color secondarySurface = colorScheme.surface;
  if (secondarySurface.alpha != 0) {
    return secondarySurface;
  }

  return colorScheme.background.withValues(alpha: 0.95);
}
