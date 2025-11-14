# FLauncher - Android TV Launcher Documentation

## Project Overview
FLauncher is a Flutter-based Android TV launcher that replaces the default Android TV home screen with a customizable interface. It organizes apps into categories, manages wallpapers, and provides TV-optimized D-pad navigation.

## Core Architecture

### Dependencies
- **Flutter**: 3.35.2 with Material Design 3
- **State Management**: Provider pattern
- **Database**: Drift ORM with SQLite
- **Platform Integration**: Method channels for native Android features
- **Localization**: flutter_localizations (English, Spanish, Dutch)

### Key Components

#### 1. Main Application Structure
- `main.dart`: Dependency injection setup with MultiProvider
- `flauncher_app.dart`: MaterialApp configuration with TV navigation shortcuts
- `flauncher.dart`: Main launcher UI with wallpaper and sections

#### 2. State Management Services
- **SettingsService**: User preferences via SharedPreferences
- **AppsService**: Application management and categorization
- **WallpaperService**: Wallpaper management (gradients, custom images, Unsplash)
- **NetworkService**: Network status monitoring
- **LauncherState**: Launcher visibility and back button handling
- **MediaService**: Media session control

#### 3. Database Schema (Drift ORM)
```dart
// Tables:
- Apps: packageName, name, version, hidden
- Categories: id, name, type, sort, rowHeight, columnsCount, order
- AppsCategories: categoryId, appPackageName, order (many-to-many)
- LauncherSpacers: id, height, order (visual spacing)
```

#### 4. Platform Channel
`FLauncherChannel` handles native Android integration:
- App discovery and launching
- Network monitoring
- Media session management
- Application icons/banners

#### 5. UI Components
- **AppsGrid**: Grid layout for applications (CategoryType.grid)
- **CategoryRow**: Horizontal row layout (CategoryType.row)
- **AppCard**: Individual application card with focus handling
- **MediaControlCard**: Media playback controls

## Key Functionality

### TV Navigation
- Custom `RowByRowTraversalPolicy` for D-pad navigation
- Sound feedback and visual focus indicators
- Back button handling with customizable actions
- Game controller support (B button for back)

### App Management
- Automatic app discovery via Android PackageManager
- Categorization with manual/alphabetical sorting
- Hidden apps support
- App launching and info access

### Wallpaper System
- Gradient backgrounds with predefined options
- Custom image selection from gallery
- Unsplash integration with API key (.env file)
- Persistent wallpaper selection

### Categories
- Two layout types: Row (horizontal) and Grid (vertical)
- Configurable dimensions (row height, column count)
- Manual ordering support
- Spacer elements for visual separation

## Rebuilding Guide

### 1. Project Setup
```bash
flutter create tv_launcher
cd tv_launcher
```

Add dependencies to `pubspec.yaml`:
- provider
- drift
- sqlite3_flutter_libs
- shared_preferences
- image_picker
- http
- flutter_localizations
- flutter_dotenv

### 2. Database Implementation
Create `database.dart` with Drift tables matching the schema above. Implement migration strategy for schema versioning.

### 3. Platform Channel
Create `flauncher_channel.dart` with method channels for:
- App discovery (`getApplications`)
- App launching (`launchApp`)
- Network monitoring
- Media session control

### 4. Android Native Code
Implement `MainActivity.java` with:
- PackageManager integration for app discovery
- Media session manager for playback control
- Network connectivity monitoring
- Event channels for real-time updates

### 5. State Management
Create provider services:
- `SettingsService` with SharedPreferences
- `AppsService` with database integration
- `WallpaperService` with file management
- `NetworkService` with platform channel events

### 6. UI Implementation
Build TV-optimized widgets:
- Focus-aware navigation with custom traversal policy
- D-pad friendly layouts with proper focus management
- Sound feedback and visual indicators
- Responsive grid/row layouts

### 7. Localization
Set up `l10n.yaml` and ARB files for multi-language support.

### 8. Configuration
- Android TV manifest entries
- Build flavors (dev/prod)
- Environment variables for API keys

## Critical Implementation Details

### TV-Specific Considerations
- All UI must work with D-pad navigation (no touch assumptions)
- Focus management is critical for usability
- Screen size and viewing distance optimizations
- Game controller button mapping

### Performance
- Lazy loading for large app lists
- Image caching and optimization
- Memory management for wallpaper images
- Efficient database queries

### Security
- API keys in .env file (gitignored)
- Proper permission handling
- Safe app launching via package names

This architecture provides a solid foundation for rebuilding a TV-optimized launcher with modern Flutter practices and comprehensive feature set.