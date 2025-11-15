# Now Playing Feature Implementation Task Brief

## Context
Remove the large MediaControlCard from the main launcher view and replace it with a compact now-playing indicator in the top AppBar status bar.

## Objective
Create a streamlined audio playback indicator in the status bar that shows:
- Play/pause toggle button
- Currently playing track information (Artist - Title)
- Only visible during active audio playback

## Implementation Tasks

### Task 1: Create NowPlayingWidget
**File**: `lib/widgets/now_playing_widget.dart`

**Requirements**:
- Only visible when `mediaService.hasActiveMedia` is true
- Display format: `[Play/Pause Icon] Artist - Title`
- Use `Consumer<MediaService>` for reactive updates
- IconButton for play/pause with `mediaService.togglePlayPause()`
- Match AppBar styling:
  - Text shadows using `PremiumShadows.textShadow(context)`
  - Color: `Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.85)`
  - Font: `Theme.of(context).textTheme.bodyMedium`
- Handle text overflow with ellipsis
- Make IconButton focusable for D-pad navigation (TV remote support)
- Icon size: 20 (match settings icon)
- Use dynamic icon based on `currentSession.isPlaying` (Icons.pause / Icons.play_arrow)

**Code Structure**:
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/providers/media_service.dart';
import 'package:flauncher/widgets/shadow_helpers.dart';

class NowPlayingWidget extends StatelessWidget {
  const NowPlayingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaService>(
      builder: (context, mediaService, _) {
        if (!mediaService.hasActiveMedia) {
          return const SizedBox.shrink();
        }

        final session = mediaService.currentSession;
        // Build compact UI with IconButton + Text
        // ...
      },
    );
  }
}
```

### Task 2: Integrate into FocusAwareAppBar
**File**: `lib/widgets/focus_aware_app_bar.dart`

**Changes**:
- Add import: `import 'package:flauncher/widgets/now_playing_widget.dart';`
- Add import: `import 'package:flauncher/providers/media_service.dart';`
- In `actions` Row (around line 108), add NowPlayingWidget BEFORE NetworkWidget
- Add appropriate spacing between widgets (suggest 12-16px padding on right of NowPlayingWidget)

**Updated Layout**:
```dart
actions: [
  Padding(
    padding: const EdgeInsets.only(top: 36),
    child: Row(
      children: [
        // NEW: Now Playing Widget
        const Padding(
          padding: EdgeInsets.only(right: 12),
          child: NowPlayingWidget(),
        ),
        // EXISTING: Network Widget
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: NetworkWidget(),
        ),
        // EXISTING: Settings Icon
        Padding(...),
      ],
    ),
  ),
],
```

### Task 3: Remove MediaControlCard from Launcher
**File**: `lib/flauncher.dart`

**Changes**:
1. Remove import on line 30:
   ```dart
   import 'package:flauncher/widgets/media_control_card.dart';
   ```

2. Remove the `_sectionsWithMedia()` method (lines 70-86)

3. Update the body builder (around line 62):
   **Before**:
   ```dart
   return SingleChildScrollView(
       child: _sectionsWithMedia(
           appsService.launcherSections));
   ```
   
   **After**:
   ```dart
   return SingleChildScrollView(
       child: Column(
           children: _buildSections(appsService.launcherSections)));
   ```

### Task 4: Delete Old Widget
**File**: `lib/widgets/media_control_card.dart`
- Delete this file entirely

### Task 5: Update Documentation
**File**: `FLAUNCHER_DOCUMENTATION.md`
- Remove line 50: `- **MediaControlCard**: Media playback controls`
- Optionally add: `- **NowPlayingWidget**: Compact audio playback indicator in status bar`

## Key References

### MediaService API
Available from `lib/providers/media_service.dart`:
- `mediaService.hasActiveMedia` - boolean, true when audio is active
- `mediaService.currentSession` - MediaSessionInfo object with:
  - `title` - Track title (nullable)
  - `artist` - Artist name (nullable)
  - `isPlaying` - boolean
  - `packageName`, `appName`, `album`, `position`, `duration`
- `mediaService.togglePlayPause()` - async method to toggle playback

### Styling References
- **DateTimeWidget**: See focus_aware_app_bar.dart lines 74-99 for text styling example
- **NetworkWidget**: See focus_aware_app_bar.dart line 112 for icon widget reference
- **Settings IconButton**: See focus_aware_app_bar.dart lines 116-136 for focusable button example

### Important Styling Details
- Use `PremiumShadows.textShadow(context)` from `shadow_helpers.dart`
- Maintain color consistency with existing AppBar elements
- Icon shadows: `Shadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 3, offset: Offset(0, 1))`
- Focus color for buttons: `Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)`

## Design Notes

### Visual Layout
```
AppBar:
  Left side: [Date] [Time]
  Right side: [▶️ Artist - Title] [Network Icon] [Settings Icon]
```

### Behavior
- Widget appears/disappears based on media playback state
- Only shows for audio (video playback won't be visible since launcher is hidden)
- IconButton is focusable for TV remote D-pad navigation
- Clicking/selecting the button toggles play/pause
- Text truncates with ellipsis if too long

### Text Format Examples
- Playing: `▶ Drake - Hotline Bling`
- Paused: `⏸ The Beatles - Hey Jude`
- Only title: `▶ Unknown Track`
- Only artist: `▶ Queen`

## Testing Checklist
After implementation, verify:
- [ ] Widget appears when audio is playing
- [ ] Widget disappears when audio stops
- [ ] Play/pause button toggles playback correctly
- [ ] Text displays artist and title properly
- [ ] Text truncates gracefully when too long
- [ ] Button is focusable with TV remote D-pad
- [ ] Styling matches existing AppBar elements (shadows, colors)
- [ ] No compilation errors
- [ ] MediaControlCard successfully removed from launcher body
- [ ] No visual regressions in AppBar layout

## File Summary

**Files to Create**:
- `lib/widgets/now_playing_widget.dart`

**Files to Modify**:
- `lib/widgets/focus_aware_app_bar.dart`
- `lib/flauncher.dart`
- `FLAUNCHER_DOCUMENTATION.md`

**Files to Delete**:
- `lib/widgets/media_control_card.dart`
