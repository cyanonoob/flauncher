# FLauncher Focus Navigation Performance Optimization Plan

## Overview
Addresses sluggish focus navigation when switching between app card rows to top bar and between icon buttons.

---

## Phase 1: HIGH IMPACT (60-70% improvement)

### 1.1 Optimize RowByRowTraversalPolicy
**File**: `lib/custom_traversal_policy.dart`

**Issues**: Line 16 creates list copy on every focus change; Line 22 creates another copy
**Changes**:
- Check if descendants list empty before processing
- Add early exit if only 1-2 candidates found
- Use where() instead of removeWhere() to avoid mutation
- Return early if candidates empty during filtering

**Impact**: 20-30% faster traversal

### 1.2 Add RepaintBoundary to Icon Buttons
**Files**: `focus_aware_app_bar.dart:129`, `network_widget.dart:78`, `now_playing_widget.dart:39`

**Wrap each IconButton**:
```dart
RepaintBoundary(child: IconButton(...))
```

**Impact**: 30-40% faster icon-to-icon navigation

### 1.3 Extract Icon Buttons to Widgets
**Create**: `settings_icon_button.dart`, `network_icon_button.dart`, `media_control_button.dart`

```dart
class SettingsIconButton extends StatelessWidget {
  const SettingsIconButton({super.key});
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: IconButton(...));
  }
}
```

**Update**: `focus_aware_app_bar.dart`, `network_widget.dart`, `now_playing_widget.dart` to use new widgets

**Impact**: 15-20% rebuild improvement

### 1.4 Debounce AppBar Auto-Hide
**File**: `lib/widgets/focus_aware_app_bar.dart:37-48`

```dart
class _FocusAwareAppBarState extends State<FocusAwareAppBar> {
  bool focused = false;
  Timer? _debounceTimer;
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  void _onFocusChange(bool hasFocus) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => focused = hasFocus);
    });
  }
}
```

**Impact**: 40-50% smoother navigation

### 1.5 AnimatedOpacity Alternative
**File**: `lib/widgets/focus_aware_app_bar.dart:39-43`

**Option A - AnimatedOpacity**:
```dart
SizedBox(
  height: kToolbarHeight + 36,
  child: AnimatedOpacity(
    curve: Curves.decelerate,
    duration: Duration(milliseconds: 250),
    opacity: focused ? 1.0 : 0.0,
    child: widget!,
  ),
)
```

**Option B - AnimatedAlign** (smoother):
```dart
ClipRect(
  child: AnimatedAlign(
    curve: Curves.decelerate,
    duration: Duration(milliseconds: 250),
    alignment: focused ? Alignment.topCenter : Alignment.bottomCenter,
    heightFactor: focused ? 1.0 : 0.0,
    child: widget!,
  ),
)
```

**Impact**: 20-30% smoother animation

---

## Phase 2: MEDIUM IMPACT (15-25% improvement)

### 2.1 Optimize AppCard ScrollEnsureVisible
**File**: `lib/widgets/app_card.dart:145-155`

```dart
class _AppCardState extends State<AppCard> {
  FocusNode? _lastFocusedNode;
  
  onFocusChange: (focused) {
    if (focused) {
      final currentNode = Focus.of(context);
      if (_lastFocusedNode != null) {
        final lastY = _lastFocusedNode!.rect.center.dy;
        final currentY = currentNode.rect.center.dy;
        
        if ((lastY - currentY).abs() > 50) {
          Scrollable.ensureVisible(context, alignment: 0.5, 
            curve: Curves.easeOutCubic, duration: Duration(milliseconds: 250));
        }
      }
      _lastFocusedNode = currentNode;
    }
  },
}
```

**Impact**: 15-20% faster horizontal navigation

### 2.2 Add Visibility Check Before Scrolling
**File**: `lib/widgets/app_card.dart:145-155`

```dart
onFocusChange: (focused) {
  if (focused) {
    final renderObject = context.findRenderObject();
    if (renderObject != null && renderObject is RenderBox) {
      final viewport = RenderAbstractViewport.of(renderObject);
      if (viewport != null) {
        final revealedOffset = viewport.getOffsetToReveal(renderObject, 0.5);
        if (revealedOffset.offset.abs() > 10) {
          Scrollable.ensureVisible(context, alignment: 0.5,
            curve: Curves.easeOutCubic, duration: Duration(milliseconds: 250));
        }
      }
    }
  }
}
```

**Impact**: 10-15% improvement

### 2.3 Cache Shadow Calculations
**Create**: `lib/widgets/shadow_cache.dart`

```dart
class ShadowCache extends InheritedWidget {
  final List<Shadow> textShadows;
  final List<Shadow> primaryTextShadows;
  final List<BoxShadow> focusedCardShadows;
  
  const ShadowCache({
    super.key, required super.child,
    required this.textShadows,
    required this.primaryTextShadows,
    required this.focusedCardShadows,
  });
  
  static ShadowCache of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShadowCache>()!;
  }
  
  @override
  bool updateShouldNotify(ShadowCache old) =>
    textShadows != old.textShadows ||
    primaryTextShadows != old.primaryTextShadows ||
    focusedCardShadows != old.focusedCardShadows;
}
```

**Update**:
- `lib/flauncher.dart` - wrap with ShadowCache
- `lib/widgets/app_card.dart` - use `ShadowCache.of(context).focusedCardShadows`
- `lib/widgets/category_row.dart` - use `ShadowCache.of(context).primaryTextShadows`

**Impact**: 5-10% rebuild reduction

---

## Builder Agent Instructions

**Rules**:
- Execute tasks sequentially
- Mark `in_progress` when starting, `completed` when done
- **STOP at PAUSE tasks** - wait for user approval before continuing
- Minimal comments - only for complex logic
- Update checklist as you progress

**Profiling Command**: `flutter run --profile --trace-skia`

---

## Task Checklist

### High Priority

- [x] 1. Profile baseline - record metrics
- [x] 2. **PAUSE** - User tests baseline
- [x] 3. RepaintBoundary: focus_aware_app_bar.dart:129
- [x] 4. RepaintBoundary: network_widget.dart:78
- [x] 5. RepaintBoundary: now_playing_widget.dart:39
- [x] 6. **PAUSE** - User tests RepaintBoundary
- [x] 7. Debounce AppBar in focus_aware_app_bar.dart
- [x] 8. **PAUSE** - User tests debounce
- [ ] 9. Optimize RowByRowTraversalPolicy - early exits
- [ ] 10. NodeSearcher.findCandidates - use where()
- [ ] 11. **PAUSE** - User tests traversal policy

### Medium Priority

- [ ] 12. Create settings_icon_button.dart
- [ ] 13. Create network_icon_button.dart
- [ ] 14. Create media_control_button.dart
- [ ] 15. Update focus_aware_app_bar.dart
- [ ] 16. Update network_widget.dart
- [ ] 17. Update now_playing_widget.dart
- [ ] 18. **PAUSE** - User tests icon widgets
- [ ] 19. AppCard focus tracking (2.1)
- [ ] 20. AppCard visibility check (2.2)
- [ ] 21. **PAUSE** - User tests AppCard

### Low Priority

- [ ] 22. AnimatedOpacity/AnimatedAlign alternative
- [ ] 23. **PAUSE** - User tests animation
- [ ] 24. Create shadow_cache.dart
- [ ] 25. Update flauncher.dart
- [ ] 26. Update app_card.dart
- [ ] 27. Update category_row.dart
- [ ] 28. **PAUSE** - User tests shadows

### Final

- [ ] 29. Run: flutter test
- [ ] 30. Profile final - compare with baseline
- [ ] 31. **PAUSE** - User final validation
- [ ] 32. Document results

**9 PAUSE points total**
