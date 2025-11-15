# Solution 5: Dynamic Theming System

## Overview
Create an intelligent theming system that adapts to wallpaper content, brightness settings, and user preferences to provide optimal visibility and a premium, context-aware user experience.

## Current Issues
- Static theme colors regardless of wallpaper
- Fixed shadow colors that don't adapt to content
- No consideration for wallpaper brightness
- Theme elements compete with wallpaper instead of complementing

## Dynamic Theming Strategy

### Adaptation Principles
- **Wallpaper-aware colors**: Extract dominant colors from wallpaper
- **Brightness adaptation**: Adjust theme based on wallpaper brightness
- **Contrast optimization**: Ensure readability across all wallpapers
- **Contextual shadows**: Shadow colors that complement wallpaper
- **Accent color harmony**: Theme accents that work with wallpaper

### Color Analysis System

#### Wallpaper Color Extraction
```dart
// lib/providers/theme_service.dart
class ThemeService extends ChangeNotifier {
  final WallpaperService _wallpaperService;
  
  Color _dominantColor = Colors.blueGrey;
  Color _accentColor = Colors.deepPurple;
  double _wallpaperBrightness = 0.5;
  bool _isDarkWallpaper = true;
  
  ThemeService(this._wallpaperService) {
    _wallpaperService.addListener(_analyzeWallpaper);
    _analyzeWallpaper();
  }
  
  Future<void> _analyzeWallpaper() async {
    if (_wallpaperService.wallpaper != null) {
      final image = _wallpaperService.wallpaper!;
      final colors = await _extractColors(image);
      _updateThemeFromColors(colors);
    } else {
      _updateThemeFromGradient(_wallpaperService.gradient);
    }
    notifyListeners();
  }
  
  Future<List<Color>> _extractColors(ImageProvider image) async {
    // Implement color extraction logic
    // Use palette generation or sampling
    return [Colors.blueGrey, Colors.deepPurple]; // Placeholder
  }
  
  void _updateThemeFromColors(List<Color> colors) {
    // Analyze colors for dominant and accent
    _dominantColor = colors.first;
    _accentColor = colors.length > 1 ? colors[1] : _dominantColor;
    _wallpaperBrightness = _calculateBrightness(_dominantColor);
    _isDarkWallpaper = _wallpaperBrightness < 0.5;
  }
  
  void _updateThemeFromGradient(FLauncherGradient gradient) {
    // Extract colors from gradient
    _dominantColor = Colors.blueGrey; // Default for gradients
    _accentColor = Colors.deepPurple;
    _wallpaperBrightness = 0.3; // Assume dark for gradients
    _isDarkWallpaper = true;
  }
  
  double _calculateBrightness(Color color) {
    return (color.red * 299 + color.green * 587 + color.blue * 114) / 255000;
  }
}
```

### Dynamic Shadow System
```dart
// lib/widgets/dynamic_shadows.dart
class DynamicShadows {
  static List<Shadow> getTextShadows(BuildContext context, Color wallpaperColor) {
    final brightness = Theme.of(context).brightness;
    final isDarkWallpaper = _isDarkColor(wallpaperColor);
    
    if (isDarkWallpaper) {
      return [
        Shadow(
          color: Colors.white.withOpacity(0.15),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        Shadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else {
      return [
        Shadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        Shadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
  }
  
  static List<BoxShadow> getCardShadows(BuildContext context, Color wallpaperColor) {
    final isDarkWallpaper = _isDarkColor(wallpaperColor);
    
    if (isDarkWallpaper) {
      return [
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];
    }
  }
  
  static bool _isDarkColor(Color color) {
    final brightness = (color.red * 299 + color.green * 587 + color.blue * 114) / 255000;
    return brightness < 0.5;
  }
}
```

### Adaptive Color System
```dart
// lib/providers/theme_service.dart (continued)
class ThemeService extends ChangeNotifier {
  // ... previous code
  
  Color get adaptiveTextColor {
    if (_isDarkWallpaper) {
      return Colors.white.withOpacity(0.95);
    } else {
      return Colors.black.withOpacity(0.87);
    }
  }
  
  Color get adaptiveSecondaryTextColor {
    if (_isDarkWallpaper) {
      return Colors.white.withOpacity(0.7);
    } else {
      return Colors.black.withOpacity(0.6);
    }
  }
  
  Color get adaptiveAccentColor {
    // Ensure accent color has sufficient contrast
    if (_isDarkWallpaper) {
      return _accentColor.withOpacity(0.9);
    } else {
      return _accentColor.withOpacity(0.8);
    }
  }
  
  Color get adaptiveGlassColor {
    if (_isDarkWallpaper) {
      return Colors.white.withOpacity(0.08);
    } else {
      return Colors.black.withOpacity(0.05);
    }
  }
  
  double get adaptiveGlassBlur {
    // More blur for busy wallpapers, less for simple ones
    return _wallpaperBrightness < 0.3 ? 16.0 : 12.0;
  }
}
```

## File Modifications

### 1. lib/providers/theme_service.dart (New File)
**Create new theme service** for dynamic theming

**Implementation**:
- Wallpaper color analysis
- Dynamic color generation
- Shadow adaptation
- Brightness calculation

### 2. lib/flauncher_app.dart
**Lines to modify**: Theme definition and provider setup

**Add theme service**:
```dart
// In main.dart or app initialization
MultiProvider(
  providers: [
    // ... existing providers
    ChangeNotifierProvider(create: (_) => ThemeService(wallpaperService)),
  ],
  child: FLauncherApp(),
)
```

**Update theme construction**:
```dart
ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Consumer<ThemeService>(
      builder: (context, themeService, _) => themeService.adaptiveAccentColor,
    ),
    secondary: Consumer<ThemeService>(
      builder: (context, themeService, _) => themeService.adaptiveAccentColor,
    ),
    surface: Colors.transparent,
    background: Consumer<ThemeService>(
      builder: (context, themeService, _) => themeService.adaptiveGlassColor,
    ),
  ),
  textTheme: TextTheme(
    titleLarge: Consumer<ThemeService>(
      builder: (context, themeService, _) => TextStyle(
        color: themeService.adaptiveTextColor,
        shadows: DynamicShadows.getTextShadows(context, themeService.dominantColor),
      ),
    ),
    titleMedium: Consumer<ThemeService>(
      builder: (context, themeService, _) => TextStyle(
        color: themeService.adaptiveTextColor,
        shadows: DynamicShadows.getTextShadows(context, themeService.dominantColor),
      ),
    ),
    headlineSmall: Consumer<ThemeService>(
      builder: (context, themeService, _) => TextStyle(
        color: themeService.adaptiveAccentColor,
        shadows: DynamicShadows.getTextShadows(context, themeService.dominantColor),
      ),
    ),
  ),
)
```

### 3. lib/widgets/focus_aware_app_bar.dart
**Lines to modify**: All text and icon styling

**Update to use dynamic colors**:
```dart
Consumer<ThemeService>(
  builder: (context, themeService, _) => Icon(
    Icons.settings_outlined,
    color: themeService.adaptiveTextColor,
    shadows: DynamicShadows.getTextShadows(context, themeService.dominantColor),
  ),
)
```

### 4. lib/widgets/network_widget.dart
**Lines to modify**: Icon styling

**Update to use dynamic colors**:
```dart
Consumer<ThemeService>(
  builder: (context, themeService, _) => Icon(
    iconData,
    color: themeService.adaptiveSecondaryTextColor,
    shadows: DynamicShadows.getTextShadows(context, themeService.dominantColor),
  ),
)
```

### 5. lib/widgets/category_row.dart
**Lines to modify**: Category title styling

**Update to use dynamic colors**:
```dart
Consumer<ThemeService>(
  builder: (context, themeService, _) => Text(
    category.name,
    style: Theme.of(context).textTheme.titleLarge!.copyWith(
      color: themeService.adaptiveTextColor,
      shadows: DynamicShadows.getTextShadows(context, themeService.dominantColor),
    ),
  ),
)
```

### 6. lib/widgets/app_card.dart
**Lines to modify**: Shadow definitions and focus animations

**Update to use dynamic shadows**:
```dart
Consumer<ThemeService>(
  builder: (context, themeService, _) => Container(
    decoration: BoxDecoration(
      boxShadow: shouldHighlight 
        ? DynamicShadows.getFocusedCardShadows(context, themeService.dominantColor)
        : DynamicShadows.getCardShadows(context, themeService.dominantColor),
    ),
    child: // ... card content
  ),
)
```

### 7. lib/widgets/glass_container.dart (if created)
**Lines to modify**: Glass effect parameters

**Update to use adaptive glass**:
```dart
Consumer<ThemeService>(
  builder: (context, themeService, _) => GlassContainer(
    blur: themeService.adaptiveGlassBlur,
    opacity: themeService.isDarkWallpaper ? 0.08 : 0.12,
    // ... other parameters
  ),
)
```

## Implementation Steps

1. **Create theme service**:
   ```bash
   touch lib/providers/theme_service.dart
   ```

2. **Implement dynamic shadows**:
   ```bash
   touch lib/widgets/dynamic_shadows.dart
   ```

3. **Add theme service to provider tree** in main.dart

4. **Update theme construction** in flauncher_app.dart

5. **Convert all UI components** to use dynamic colors

6. **Implement wallpaper color analysis** (may require image processing package)

7. **Test across different wallpapers** and brightness settings

## Testing Checklist

- [ ] Theme adapts to image wallpapers
- [ ] Theme adapts to gradient wallpapers
- [ ] Text remains readable on all wallpapers
- [ ] Shadows complement wallpaper colors
- [ ] Performance remains smooth during theme changes
- [ ] Theme updates when wallpaper changes
- [ ] Glass effects adapt to wallpaper brightness
- [ ] Accent colors have sufficient contrast

## Expected Outcome

- Intelligent theme that adapts to wallpaper content
- Optimal readability across all wallpaper types
- Premium, context-aware user experience
- Dynamic shadows that complement rather than compete
- Adaptive glass effects based on wallpaper complexity
- Professional, first-party theming quality
- Better integration between UI and wallpaper