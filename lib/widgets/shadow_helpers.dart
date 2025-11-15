import 'package:flutter/material.dart';

/// Premium shadow system for FLauncher
/// 
/// For static widgets: Call methods directly in build()
/// For stateful widgets: Cache results in didChangeDependencies()
/// For animations: Pre-compute base shadows, then apply animation values
class PremiumShadows {
  // Text shadow for icons and labels
  static List<Shadow> textShadow(BuildContext context) => [
    Shadow(
      color: Theme.of(context).cardColor.withValues(alpha: 0.7),  // blueGrey[800] at 70%
      offset: const Offset(0, 1),
      blurRadius: 4,
    ),
    Shadow(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),  // deepPurple[400] at 10%
      offset: const Offset(0, 2),
      blurRadius: 8,
    ),
  ];
  
  // Stronger shadow for primary text like category headers
  static List<Shadow> primaryTextShadow(BuildContext context) => [
    Shadow(
      color: Theme.of(context).cardColor.withValues(alpha: 0.8),  // blueGrey[800] at 80%
      offset: const Offset(0, 2),
      blurRadius: 6,
    ),
    Shadow(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),  // deepPurple[400] at 20%
      offset: const Offset(0, 3),
      blurRadius: 12,
    ),
  ];
  
  // Default card shadow for unfocused state
  static List<BoxShadow> cardShadow(BuildContext context) => [
    BoxShadow(
      color: Theme.of(context).cardColor.withValues(alpha: 0.3),  // blueGrey[800] at 30%
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),  // deepPurple[400] at 8%
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];
  
  // Enhanced shadow for focused cards (TV navigation)
  static List<BoxShadow> focusedCardShadow(BuildContext context) => [
    BoxShadow(
      color: Theme.of(context).cardColor.withValues(alpha: 0.4),  // blueGrey[800] at 40%
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),  // deepPurple[400] at 15%
      offset: const Offset(0, 16),
      blurRadius: 32,
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),  // deepPurple[300] at 5%
      offset: const Offset(0, 24),
      blurRadius: 48,
      spreadRadius: -16,
    ),
  ];
}