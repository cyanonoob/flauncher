# Solution 4: Glass-morphism Elements (Performance Optimized)

## Overview
Implement modern glass-morphism effects throughout the UI to create depth, sophistication, and a premium first-party appearance. This includes frosted glass backgrounds, subtle transparency, and gradient overlays that complement the wallpaper.

**PERFORMANCE FIRST**: This implementation prioritizes Android TV performance by avoiding nested BackdropFilters, providing degraded modes for lower-end devices, and using caching strategies.

## Current Issues
- Flat, transparent backgrounds
- No depth perception in UI elements
- Status bar lacks visual separation from content
- Settings panels appear basic and dated

## Glass-morphism Strategy

### Design Principles
- **Performance-aware blur**: Backdrop blur only where necessary, avoiding nesting
- **Gradient overlays**: Complement wallpaper colors without GPU overhead
- **Layered transparency**: Multiple transparency levels for depth
- **Subtle borders**: Soft borders with gradient colors
- **Adaptive quality**: Blur intensity based on device capabilities

### Visual Effects Hierarchy

#### Level 1: Status Bar (Primary Glass) - ~~SKIPPED~~ ❌
**PERFORMANCE ISSUE**: Tested and reverted. BackdropFilter on status bar causes poor performance on Android TV, even with optimizations. Do not implement.
- ~~**Blur**: 8px backdrop blur (reduced from 12px)~~
- ~~**Opacity**: 0.12 background opacity~~
- ~~**Border**: 1px subtle gradient border~~
- ~~**Gradient**: Subtle vertical gradient overlay~~
- ~~**Optimization**: Single BackdropFilter, no nested children with blur~~

#### Level 2: Settings Panels (Secondary Glass)
- **Blur**: 10px backdrop blur (temporary UI, acceptable)
- **Opacity**: 0.18 background opacity
- **Border**: 1px soft border
- **Shadow**: Subtle shadow for elevation
- **Optimization**: RepaintBoundary for caching

#### Level 3: Dialogs (Tertiary Glass)
- **Blur**: 12px backdrop blur (reduced from 16px)
- **Opacity**: 0.22 background opacity
- **Border**: Gradient border
- **Shadow**: Elevated shadow system
- **Optimization**: RepaintBoundary for caching

## Performance Optimizations

### Critical Rules
1. **NO NESTED BACKDROPFILTERS** - Only one blur layer per visual hierarchy
2. **Use RepaintBoundary** - Cache expensive blur operations
3. **Conditional blur quality** - Settings option to reduce/disable blur
4. **Solid fallback** - Semi-transparent backgrounds when blur disabled

## Implementation Details

### Performance-Aware Glass Container Widget
```dart
// lib/widgets/glass_container.dart
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
  final bool enableBlur; // NEW: Allow disabling blur for nested containers

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
    this.enableBlur = true, // NEW: Default enabled
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // NEW: Check performance settings
    final settings = context.watch<SettingsService>();
    final useBlur = enableBlur && settings.glassEffectsEnabled;
    final effectiveBlur = settings.highQualityEffects ? blur : blur * 0.6;
    
    return RepaintBoundary( // NEW: Cache this expensive widget
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
                    tileMode: TileMode.clamp, // NEW: Prevent edge artifacts
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      color: Colors.white.withOpacity(opacity),
                      gradient: gradient ?? _defaultGradient(context),
                    ),
                  ),
                )
              else
                // NEW: Solid fallback when blur disabled
                Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
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
      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      width: 1.0,
    );
  }

  List<BoxShadow> _defaultShadow(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
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
        Theme.of(context).colorScheme.primary.withOpacity(0.05),
        Theme.of(context).colorScheme.secondary.withOpacity(0.02),
        Colors.transparent,
      ],
    );
  }
}
```

### Optimized Status Bar Implementation
```dart
// Enhanced FocusAwareAppBar with glass-morphism
// CRITICAL: No nested GlassContainers - use simple styled containers for children
class _FocusAwareAppBarState extends State<FocusAwareAppBar> {
  @override
  Widget build(BuildContext context) {
    return Selector<SettingsService, bool>(
      selector: (_, settings) => settings.autoHideAppBarEnabled,
      builder: (context, autoHide, widget) {
        if (autoHide) {
          return Focus(
            canRequestFocus: false,
            child: AnimatedContainer(
              curve: Curves.decelerate,
              duration: const Duration(milliseconds: 300),
              height: focused ? kToolbarHeight : 0,
              child: widget!,
            ),
            onFocusChange: (hasFocus) {
              setState(() => focused = hasFocus);
            },
          );
        }

        // OPTIMIZED: Single GlassContainer for entire status bar
        return GlassContainer(
          blur: 8.0, // Reduced from 12.0 for performance
          opacity: 0.12,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              _buildSettingsButton(context),
              _buildNetworkWidget(context),
              _buildDateTimeWidgets(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(
          Icons.settings_outlined,
          color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.9),
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        onPressed: () => showDialog(
          context: context, 
          builder: (_) => const SettingsPanel()
        ),
        focusColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
    );
  }

  // CRITICAL: No nested GlassContainer - use simple Container instead
  Widget _buildNetworkWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: const NetworkWidget(),
    );
  }

  // CRITICAL: No nested GlassContainer - use simple Container instead
  Widget _buildDateTimeWidgets(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: _buildDateTimeContent(context),
    );
  }
}
```

### Optimized Settings Panel
```dart
// Enhanced settings panel with glass-morphism
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 10.0, // Reduced from 16.0
      opacity: 0.18,
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.08),
          Theme.of(context).colorScheme.secondary.withOpacity(0.04),
          Colors.transparent,
        ],
      ),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
      child: const SettingsPanelContent(),
    );
  }
}
```

## Settings Service Updates

### Add Glass Effects Settings
```dart
// lib/providers/settings_service.dart
// Add these properties and methods:

class SettingsService extends ChangeNotifier {
  // ... existing properties ...
  
  // NEW: Glass effects settings
  bool _glassEffectsEnabled = true;
  bool _highQualityEffects = true; // Auto-detect or user preference
  
  bool get glassEffectsEnabled => _glassEffectsEnabled;
  bool get highQualityEffects => _highQualityEffects;
  
  Future<void> setGlassEffectsEnabled(bool enabled) async {
    _glassEffectsEnabled = enabled;
    await _prefs.setBool('glassEffectsEnabled', enabled);
    notifyListeners();
  }
  
  Future<void> setHighQualityEffects(bool enabled) async {
    _highQualityEffects = enabled;
    await _prefs.setBool('highQualityEffects', enabled);
    notifyListeners();
  }
  
  // In init method, add:
  // _glassEffectsEnabled = _prefs.getBool('glassEffectsEnabled') ?? true;
  // _highQualityEffects = _prefs.getBool('highQualityEffects') ?? _detectHighEndDevice();
  
  // NEW: Auto-detect device capability (optional)
  bool _detectHighEndDevice() {
    // For Android TV, conservative default
    // Could use platform channels to check RAM/GPU if needed
    return false; // Default to performance mode
  }
}
```

## File Modifications

### 1. lib/providers/settings_service.dart
**Add glass effects settings** as shown above

### 2. lib/widgets/glass_container.dart
**Create new file** with optimized GlassContainer implementation

### 3. lib/widgets/focus_aware_app_bar.dart
**Complete restructuring required** - wrap entire AppBar in single GlassContainer

**Key changes**:
- Replace transparent AppBar with single GlassContainer
- NO nested GlassContainers for network/datetime widgets
- Use simple Containers with styling for nested elements
- Add RepaintBoundary for performance

### 4. lib/widgets/right_panel_dialog.dart
**Lines to modify**: 30-40 (Dialog structure)

**Replace**:
```dart
return Dialog(
  backgroundColor: Theme.of(context).colorScheme.background,
  // ... existing content
);
```

**With**:
```dart
return Dialog(
  backgroundColor: Colors.transparent,
  insetPadding: EdgeInsets.only(
    left: MediaQuery.of(context).size.width - width - 16,
    right: 16,
    top: 16,
    bottom: 16,
  ),
  child: GlassContainer(
    blur: 12.0, // Reduced from 16.0
    opacity: 0.2,
    borderRadius: BorderRadius.circular(16),
    child: child,
  ),
);
```

### 5. lib/widgets/settings/ (all settings panels)
**Update all settings dialogs** to use GlassContainer:
- `applications_panel_page.dart`
- `wallpaper_panel_page.dart`
- `category_panel_page.dart`
- etc.

**NOTE**: If panels have list items that need glass effect, use `enableBlur: false` for nested items

### 6. lib/widgets/add_to_category_dialog.dart
**Lines to modify**: 44-50 (Card styling)

**Replace**:
```dart
Card(
  clipBehavior: Clip.antiAlias,
  color: Theme.of(context).cardColor,
  elevation: 0,
  child: ListTile(
    // ... content
  ),
)
```

**With**:
```dart
// If inside a GlassContainer parent, disable blur:
GlassContainer(
  enableBlur: false, // CRITICAL: Parent already has blur
  opacity: 0.1,
  borderRadius: BorderRadius.circular(12),
  padding: EdgeInsets.zero,
  child: ListTile(
    // ... content
  ),
)

// Or use simple Container for better performance:
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      width: 1.0,
    ),
  ),
  child: ListTile(
    // ... content
  ),
)
```

### 7. lib/widgets/settings/settings_panel_page.dart
**Add glass effects toggle** in appearance/performance settings:

```dart
SwitchListTile(
  title: const Text('Glass Effects'),
  subtitle: const Text('Frosted glass blur effects (may impact performance)'),
  value: settings.glassEffectsEnabled,
  onChanged: (value) => settings.setGlassEffectsEnabled(value),
),
SwitchListTile(
  title: const Text('High Quality Effects'),
  subtitle: const Text('Higher blur quality (more GPU intensive)'),
  value: settings.highQualityEffects,
  onChanged: (value) => settings.setHighQualityEffects(value),
  enabled: settings.glassEffectsEnabled,
),
```

## Implementation Steps

1. **Update SettingsService** with glass effects settings
   - Add properties and persistence
   - Add device detection (optional)

2. **Create GlassContainer widget**:
   ```bash
   touch lib/widgets/glass_container.dart
   ```

3. **Implement optimized GlassContainer** with:
   - RepaintBoundary caching
   - Conditional blur based on settings
   - Solid fallback mode
   - enableBlur flag for nested contexts

4. **Update FocusAwareAppBar** with SINGLE glass container
   - Remove nested GlassContainers
   - Use simple Containers for network/datetime
   - Test performance

5. **Enhance settings panels** with glass effects
   - Add glass effects toggle
   - Apply to all settings dialogs

6. **Update dialogs** throughout the app
   - Ensure no nested BackdropFilters
   - Use enableBlur: false when appropriate

7. **Performance testing** on Android TV
   - Monitor frame rates
   - Test on lower-end devices
   - Adjust blur values if needed

## Performance Testing Checklist

- [ ] **FPS monitoring**: Maintain 60fps on home screen
- [ ] **Status bar performance**: No frame drops with glass effect
- [ ] **Settings panel smooth**: Dialogs open/close without lag
- [ ] **Memory usage**: No excessive memory consumption
- [ ] **Low-end device test**: Test with glass effects disabled
- [ ] **Blur quality settings**: Verify degraded mode works
- [ ] **RepaintBoundary effective**: Confirm caching works
- [ ] **No nested BackdropFilters**: Code review verification

## Visual Quality Checklist

- [ ] Glass effects visible on light wallpapers
- [ ] Glass effects visible on dark wallpapers
- [ ] Glass effects visible on gradient wallpapers
- [ ] Text remains readable through glass
- [ ] Blur effects work on all devices
- [ ] Borders and gradients render correctly
- [ ] Focus states work with glass elements
- [ ] Fallback mode looks acceptable

## Performance Targets

- **Home screen**: 60fps constant
- **Status bar**: <1ms overhead per frame
- **Dialog open**: <16ms (single frame)
- **Settings toggle**: Instant response
- **Memory**: <10MB increase for glass effects

## Expected Outcome

- Modern, premium glass-morphism design
- **60fps performance** on Android TV devices
- Enhanced depth perception and visual hierarchy
- Sophisticated transparency effects
- Better integration with wallpaper content
- Professional, first-party appearance
- **User-controllable effects** for device capability
- Graceful degradation on lower-end devices
- Consistent glass design language throughout app
- **Zero nested BackdropFilters**

## Fallback Strategy

If performance issues persist:
1. Reduce blur values further (6px status bar, 8px dialogs)
2. Default to glassEffectsEnabled = false
3. Use only gradient overlays without blur
4. Implement blur only on dialogs (temporary UI)
5. Consider pre-rendered blur textures for status bar
