# FLauncher Agent Documentation

This guide helps agents understand and work with the FLauncher codebase effectively.

## Project Overview

FLauncher is an open-source Android TV launcher built with Flutter. It replaces the default Android TV home screen with a customizable interface that organizes apps into categories, manages wallpapers, and provides TV-optimized navigation.

**Key Characteristics:**
- Flutter 3.35.2 with Material Design 3
- TV-optimized UI with D-pad navigation support
- Provider-based state management
- Drift ORM for SQLite database
- Multi-language support (English, Spanish, Dutch)
- Platform-specific Android integration via method channels

## Development Environment Setup

### Required Tools
- **Flutter**: 3.35.2 (managed by mise)
- **Java**: Zulu 23.32.11 (managed by mise)
- **Kotlin**: 1.9.0 (managed by mise)
- **mise**: For dependency management

### Environment Configuration
```bash
# Install dependencies with mise
mise install

# Load environment variables (contains Unsplash API key)
cp .env.example .env  # Edit .env with your API key
```

### Development Commands
```bash
# Run development build
mise run run:dev

# Build production APK
mise run build

# Install production APK
mise run run:prod

# Uninstall development version
mise run clean:dev
```

## Architecture Overview

### State Management
The app uses **Provider pattern** with 5 main services:

1. **SettingsService** (`lib/providers/settings_service.dart`)
   - User preferences and app configuration
   - Persists to SharedPreferences

2. **AppsService** (`lib/providers/apps_service.dart`)
   - Application management and categorization
   - Database operations for apps and categories

3. **WallpaperService** (`lib/providers/wallpaper_service.dart`)
   - Wallpaper management (gradients, custom images, Unsplash)
   - Settings persistence

4. **NetworkService** (`lib/providers/network_service.dart`)
   - Network status monitoring
   - Connection state display

5. **LauncherState** (`lib/providers/launcher_state.dart`)
   - Launcher visibility and back button handling
   - Alternative view management

### Database Schema
**ORM**: Drift with SQLite
**Schema Version**: 7 (with migration support)

**Tables:**
- `apps` - Application metadata (package name, version, hidden flag)
- `categories` - Category configuration (name, type, dimensions, order)
- `apps_categories` - Many-to-many relationship with ordering
- `launcher_spacers` - Visual spacing between sections

**Models**: `App` and `Category` classes in `lib/models/`

### Platform Integration
**FLauncherChannel** (`lib/flauncher_channel.dart`)
- Method channel for app management and launching
- Event channels for app changes and network monitoring
- Native Android implementation in `MainActivity.java`

## Key File Locations

### Core Application
- `lib/main.dart` - App initialization and dependency injection
- `lib/flauncher_app.dart` - Root MaterialApp configuration
- `lib/flauncher.dart` - Main launcher UI with wallpaper and sections

### Services & Providers
- `lib/providers/` - All state management services
- `lib/flauncher_channel.dart` - Platform channel communication

### Database
- `lib/database.dart` - Database definition and connection
- `lib/database.drift.dart` - Generated database code (don't edit)
- `drift_schemas/` - Database schema versions for migrations

### UI Components
- `lib/widgets/apps_grid.dart` - Grid layout for applications
- `lib/widgets/category_row.dart` - Horizontal row layout
- `lib/widgets/app_card.dart` - Individual application card
- `lib/widgets/settings/` - Comprehensive settings panels

### Models
- `lib/models/app.dart` - Application data model
- `lib/models/category.dart` - Category configuration model

### Platform Code
- `android/app/src/main/java/me/efesser/flauncher/MainActivity.java`
- Android-specific implementations for app discovery and launching

### Localization
- `lib/l10n/` - Translation files and generated classes
- `l10n.yaml` - Localization configuration

## Development Patterns

### Code Style
- Follows Flutter/Dart conventions with flutter_lints
- Custom rule: `await_only_futures` enforced
- Generated files excluded from analysis (see `analysis_options.yaml`)

### Testing Structure
- Unit tests: `test/providers/`
- Widget tests: `test/widgets/`
- Database tests: `test/database_*.dart`
- Test helpers: `test/helpers.dart`
- Mocks: `test/mocks.dart` and `test/mocks.mocks.dart`

### Build Configuration
- **Development flavor**: `com.geert.flauncher.dev`
- **Production flavor**: `com.geert.flauncher`
- Build flavors configured in `android/app/build.gradle`

### TV Navigation
- Custom focus management: `RowByRowTraversalPolicy`
- D-pad optimized with `FocusTraversalGroup`
- Sound feedback and visual focus indicators

## Common Tasks

### Adding New Settings
1. Add property to `SettingsService`
2. Update SharedPreferences persistence
3. Add UI control in appropriate settings panel
4. Add localization strings

### Modifying Categories
1. Update `Category` model if needed
2. Modify database schema in `database.dart`
3. Update migration logic
4. Adjust UI components (`CategoryRow` or `AppsGrid`)

### Adding New Wallpaper Types
1. Extend `WallpaperService` with new type
2. Add UI controls in `wallpaper_panel_page.dart`
3. Update wallpaper rendering logic in `flauncher.dart`

### Platform Channel Changes
1. Update method signatures in `FLauncherChannel`
2. Modify native implementation in `MainActivity.java`
3. Update event stream handling if needed

## Testing Guidelines

### Running Tests
```bash
flutter test
flutter test test/providers/apps_service_test.dart  # Specific test
```

### Test Patterns
- Use `mockito` for service mocking
- Use `network_image_mock` for UI tests with images
- Test database migrations with schema versions
- Widget tests use `test/helpers.dart` for common finders

### Database Testing
- Test all migrations in `database_migration_test.dart`
- Use in-memory database for unit tests
- Verify schema consistency with generated files

## Localization

### Adding New Translations
1. Update ARB files in `lib/l10n/`
2. Run `flutter gen-l10n` to generate classes
3. Use `AppLocalizations` in UI code

### Supported Languages
- English (default)
- Spanish
- Dutch

## Important Notes

### Environment Variables
- `.env` file contains Unsplash API key
- Required for wallpaper functionality
- Add to `.gitignore` (already included)

### Database Migrations
- Always create new migration when schema changes
- Test migrations thoroughly
- Keep schema versions in `drift_schemas/`

### TV-Specific Considerations
- All UI must work with D-pad navigation
- Focus management is critical
- Test on actual Android TV device when possible
- Consider screen size and viewing distance

### Performance
- Use lazy loading for large app lists
- Optimize image loading and caching
- Consider memory usage for wallpaper images

## Troubleshooting

### Common Issues
- **Build failures**: Check Flutter version and mise configuration
- **Database errors**: Verify migrations and schema consistency
- **Platform channel issues**: Check method signatures between Dart and Java
- **Navigation problems**: Verify focus management and TV optimization

### Debug Commands
```bash
# Check Flutter environment
flutter doctor -v

# Clean build
flutter clean && mise run run:dev

# Database inspection
# Use drift_local_storage_inspector in dev builds
```

This documentation should help future agents understand the codebase structure and work effectively with FLauncher.
