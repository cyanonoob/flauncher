# Solution 3: Premium Focus Animations - Refinement

## Overview
Refine app card focus animations to be more subtle and premium. Current implementation uses aggressive 1.12 scale and simple elevation. Target: gentle 1.05 scale with multi-layered glow effects and animated borders.

## Current State

### ✅ Already Working Well
- Smart scroll behavior with viewport awareness
- Animated gradient overlay on focus  
- Premium shadow system cached for performance
- Smooth `Curves.easeOutCubic` transitions
- Consistent focus colors (0.4 alpha) across UI

### ❌ Needs Improvement
- Scale too aggressive: 1.0 → 1.12 (jarring on TV)
- Simple PhysicalModel elevation instead of layered shadows
- Single animation controller (no separate glow pulse)
- Missing animated accent border on focus
- Linear gradient instead of radial center glow

## Changes Required

### 1. Gentler Scale Animation
**Change**: `app_card.dart:126`  
**From**: `scale: shouldHighlight ? 1.12 : 1.0`  
**To**: `scale: shouldHighlight ? 1.05 : 1.0`

### 2. Dual Animation Controllers
**Change**: `app_card.dart:66` - Update mixin to `TickerProviderStateMixin`  
**Add**: Two controllers instead of one
- **Focus controller** (400ms): Scale, border, shadows
- **Glow controller** (2000ms): Continuous pulse effect

```dart
late final AnimationController _focusController = AnimationController(
  duration: const Duration(milliseconds: 400),
  vsync: this,
);

late final AnimationController _glowController = AnimationController(
  duration: const Duration(milliseconds: 2000),
  vsync: this,
);

late final Animation<double> _scaleAnimation = Tween<double>(
  begin: 1.0, end: 1.05,
).animate(CurvedAnimation(parent: _focusController, curve: Curves.easeOutCubic));

late final Animation<double> _glowAnimation = Tween<double>(
  begin: 0.3, end: 0.8,
).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

late final Animation<double> _borderAnimation = Tween<double>(
  begin: 0.0, end: 1.0,
).animate(CurvedAnimation(parent: _focusController, curve: Curves.easeOutCubic));
```

### 3. Animated Border Glow
**Add**: 2px accent-colored border that fades in on focus

```dart
border: shouldHighlight ? Border.all(
  color: Theme.of(context).colorScheme.primary.withValues(
    alpha: _borderAnimation.value * 0.6
  ),
  width: 2.0,
) : null,
```

### 4. Replace PhysicalModel with BoxShadow System
**Change**: `app_card.dart:127-131`  
**Remove**: `PhysicalModel(elevation: shouldHighlight ? 12 : 4)`  
**Replace with**: Container using `PremiumShadows` + animated accent glow

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: /* animated border from #3 */,
    boxShadow: shouldHighlight 
      ? _buildAnimatedFocusedShadows(context)
      : PremiumShadows.cardShadow(context),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: /* existing Material stack */,
  ),
)
```

**Add helper method**:
```dart
List<BoxShadow> _buildAnimatedFocusedShadows(BuildContext context) {
  final base = _baseFocusedShadows;
  return [
    BoxShadow(
      color: base[0].color.withValues(alpha: base[0].color.a * _scaleAnimation.value),
      blurRadius: base[0].blurRadius,
      offset: base[0].offset,
      spreadRadius: base[0].spreadRadius,
    ),
    BoxShadow(
      color: base[1].color.withValues(alpha: base[1].color.a * _scaleAnimation.value),
      blurRadius: base[1].blurRadius,
      offset: base[1].offset,
      spreadRadius: base[1].spreadRadius,
    ),
    BoxShadow(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: _glowAnimation.value * 0.3),
      blurRadius: 30 + (20 * _glowAnimation.value),
      offset: Offset.zero,
      spreadRadius: 2 * _glowAnimation.value,
    ),
  ];
}
```

### 5. Radial Glow Overlay
**Change**: `app_card.dart:230-240`  
**Replace**: Linear gradient with radial gradient from center

```dart
if (shouldHighlight && settingsService.appHighlightAnimationEnabled)
  AnimatedBuilder(
    animation: _glowController,
    builder: (context, _) => IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(
                alpha: _glowAnimation.value * 0.1
              ),
              Colors.transparent,
            ],
          ),
        ),
      ),
    ),
  ),
```

### 6. Focus Change Handler
**Update**: `app_card.dart:147` onFocusChange callback  
**Add controller management**:

```dart
onFocusChange: (focused) {
  if (focused) {
    _focusController.forward();
    _glowController.repeat(reverse: true);
    
    // ... existing scroll logic ...
  } else {
    _focusController.reverse();
    _glowController.stop();
    _glowController.reset();
  }
},
```

**Update dispose**:
```dart
@override
void dispose() {
  FocusManager.instance.removeHighlightModeListener(_focusHighlightModeChanged);
  _animation.dispose();
  _focusController.dispose();
  _glowController.dispose();
  super.dispose();
}
```

### 7. Settings Panel Focus Consistency
**Files**: `lib/widgets/settings/*.dart` (all settings pages)  
**Add**: Consistent focusColor to TextButtons

```dart
TextButton(
  style: TextButton.styleFrom(
    focusColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
  ),
  child: /* existing */,
  onPressed: /* existing */,
)
```

## Files to Modify
- `lib/widgets/app_card.dart` - Main animation refactor
- `lib/widgets/settings/settings_panel_page.dart` - Add focusColor
- `lib/widgets/settings/applications_panel_page.dart` - Add focusColor
- `lib/widgets/settings/wallpaper_panel_page.dart` - Add focusColor
- `lib/widgets/settings/launcher_sections_panel_page.dart` - Add focusColor
- All other settings panel files - Add focusColor

## Testing Checklist
- [ ] Scale is 1.05 (subtle, not jarring)
- [ ] Border glow fades in smoothly
- [ ] Radial glow pulses continuously when focused
- [ ] Shadow depth increases with multiple layers
- [ ] D-pad navigation smooth
- [ ] 60fps performance maintained
- [ ] Works with `appHighlightAnimationEnabled` toggle
- [ ] No animation conflicts on rapid focus changes
- [ ] Settings panels have consistent focus styling

## Expected Results
- Gentler, more premium focus feedback
- Multi-layered depth with accent glow
- Continuous pulsing animation keeps UI alive
- Subtle animated border draws attention
- Consistent focus language across entire app
- Professional polish matching first-party TV launchers

## Model Recommendation
**Use: claude-3.7-sonnet** for implementation
- Complex animation refactoring with multiple controllers
- Requires careful integration with existing animation system
- Need to preserve smart scroll logic and performance optimizations
- Multi-file consistency updates across settings panels

Alternative: **grok-2-1212** if sonnet unavailable (good with Flutter animations)
