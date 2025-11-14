import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/models/category.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/app_card.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../helpers.dart';
import '../mocks.mocks.dart';

void main() {
  group('AppCard GPU Optimizations', () {
    late App testApp;
    late Category testCategory;
    late MockAppsService mockAppsService;
    late MockSettingsService mockSettingsService;

    setUp(() {
      testApp = App(
        packageName: 'com.test.app',
        name: 'Test App',
        version: '1.0.0',
        hidden: false,
      );
      testCategory = Category(
        id: 1,
        name: 'Test Category',
        type: CategoryType.row,
        sort: CategorySort.manual,
        order: 0,
      );
      mockAppsService = MockAppsService();
      mockSettingsService = MockSettingsService();
      
      // Mock the getAppBanner and getAppIcon methods with proper image data
      // Create a simple 1x1 PNG image data
      final pngBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 image
        0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, // 8-bit, RGBA
        0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
        0x54, 0x08, 0x99, 0x01, 0x01, 0x01, 0x00, 0x00, // Minimal data
        0xFE, 0xFF, 0x00, 0x00, 0x00, 0x02, 0x00, 0x01, // CRC
        0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, // IEND chunk
        0xAE, 0x42, 0x60, 0x82, // CRC
      ]);
      
      when(mockAppsService.getAppBanner(any)).thenAnswer((_) async => pngBytes);
      when(mockAppsService.getAppIcon(any)).thenAnswer((_) async => pngBytes);
      
      // Mock settings service
      when(mockSettingsService.appHighlightAnimationEnabled).thenReturn(false);
    });

testWidgets('should have Transform widget for scaling animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<AppsService>(create: (_) => mockAppsService),
                ChangeNotifierProvider<SettingsService>(create: (_) => mockSettingsService),
              ],
              child: AppCard(
                application: testApp,
                category: testCategory,
                autofocus: false,
                onMove: (direction) {},
                onMoveEnd: () {},
              ),
            ),
          ),
        ),
      );

      // Find the AppCard and its Transform widget
      final appCardFinder = find.byType(AppCard);
      expect(appCardFinder, findsOneWidget);

      // Find Transform widgets within the AppCard
      final transformFinder = find.descendant(
        of: appCardFinder,
        matching: find.byType(Transform),
      );
      expect(transformFinder, findsOneWidget);

      // Get the Transform widget and verify it exists for GPU optimization
      final transformWidget = tester.widget<Transform>(transformFinder);
      expect(transformWidget, isNotNull);
      expect(transformWidget.transform.storage[0], equals(1.0)); // Initial scale
    });

    testWidgets('should use RepaintBoundary for GPU optimization', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<AppsService>(create: (_) => mockAppsService),
                ChangeNotifierProvider<SettingsService>(create: (_) => mockSettingsService),
              ],
              child: AppCard(
                application: testApp,
                category: testCategory,
                autofocus: false,
                onMove: (direction) {},
                onMoveEnd: () {},
              ),
            ),
          ),
        ),
      );

      // Find RepaintBoundary within the AppCard
      final appCardFinder = find.byType(AppCard);
      final repaintBoundaryFinder = find.descendant(
        of: appCardFinder,
        matching: find.byType(RepaintBoundary),
      );
      
      // Verify RepaintBoundary is present for GPU optimization
      expect(repaintBoundaryFinder, findsOneWidget);
    });

    testWidgets('should have PhysicalModel with border radius for GPU optimization', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<AppsService>(create: (_) => mockAppsService),
                ChangeNotifierProvider<SettingsService>(create: (_) => mockSettingsService),
              ],
              child: AppCard(
                application: testApp,
                category: testCategory,
                autofocus: false,
                onMove: (direction) {},
                onMoveEnd: () {},
              ),
            ),
          ),
        ),
      );

      // Find PhysicalModel within the AppCard
      final appCardFinder = find.byType(AppCard);
      final physicalModelFinder = find.descendant(
        of: appCardFinder,
        matching: find.byType(PhysicalModel),
      );
      expect(physicalModelFinder, findsWidgets);

      // Get the PhysicalModel widget with border radius (the main card one)
      final physicalModels = tester.widgetList<PhysicalModel>(physicalModelFinder);
      final mainPhysicalModel = physicalModels.firstWhere(
        (model) => model.borderRadius == BorderRadius.circular(12.0),
        orElse: () => physicalModels.first,
      );
      
      // Should have border radius for rounded corners
      expect(mainPhysicalModel.borderRadius, BorderRadius.circular(12.0));
      // Should have initial elevation for shadow
      expect(mainPhysicalModel.elevation, equals(4.0));
    });

    testWidgets('should have AnimatedPadding for dynamic spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<AppsService>(create: (_) => mockAppsService),
                ChangeNotifierProvider<SettingsService>(create: (_) => mockSettingsService),
              ],
              child: AppCard(
                application: testApp,
                category: testCategory,
                autofocus: false,
                onMove: (direction) {},
                onMoveEnd: () {},
              ),
            ),
          ),
        ),
      );

      // Find AnimatedPadding within the AppCard
      final appCardFinder = find.byType(AppCard);
      final paddingFinder = find.descendant(
        of: appCardFinder,
        matching: find.byType(AnimatedPadding),
      );
      expect(paddingFinder, findsOneWidget);

      // Get the AnimatedPadding widget
      final padding = tester.widget<AnimatedPadding>(paddingFinder);
      
      // Should have initial horizontal padding
      expect(padding.padding, equals(const EdgeInsets.symmetric(horizontal: 6)));
      // Should have animation duration for smooth transitions
      expect(padding.duration, equals(const Duration(milliseconds: 250)));
      // Should have easeOutCubic curve for natural feel
      expect(padding.curve, equals(Curves.easeOutCubic));
    });

    testWidgets('should animate with Curves.easeOutCubic and 250ms duration for padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<AppsService>(create: (_) => mockAppsService),
                ChangeNotifierProvider<SettingsService>(create: (_) => mockSettingsService),
              ],
              child: AppCard(
                application: testApp,
                category: testCategory,
                autofocus: false,
                onMove: (direction) {},
                onMoveEnd: () {},
              ),
            ),
          ),
        ),
      );

      // Find the AnimatedPadding widget
      final animatedPaddingFinder = find.byType(AnimatedPadding);
      expect(animatedPaddingFinder, findsOneWidget);

      // Get the AnimatedPadding widget
      final animatedPadding = tester.widget<AnimatedPadding>(animatedPaddingFinder);
      
      // Verify curve and duration
      expect(animatedPadding.curve, equals(Curves.easeOutCubic));
      expect(animatedPadding.duration, equals(const Duration(milliseconds: 250)));
    });

    testWidgets('should have correct aspect ratio for TV layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<AppsService>(create: (_) => mockAppsService),
                ChangeNotifierProvider<SettingsService>(create: (_) => mockSettingsService),
              ],
              child: AppCard(
                application: testApp,
                category: testCategory,
                autofocus: false,
                onMove: (direction) {},
                onMoveEnd: () {},
              ),
            ),
          ),
        ),
      );

      // Find the AspectRatio widget
      final aspectRatioFinder = find.byType(AspectRatio);
      expect(aspectRatioFinder, findsOneWidget);

      // Get the AspectRatio widget
      final aspectRatio = tester.widget<AspectRatio>(aspectRatioFinder);
      
      // Verify 16:9 aspect ratio for TV
      expect(aspectRatio.aspectRatio, equals(16.0 / 9.0));
    });

    testWidgets('should display app information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<AppsService>(create: (_) => mockAppsService),
                ChangeNotifierProvider<SettingsService>(create: (_) => mockSettingsService),
              ],
              child: AppCard(
                application: testApp,
                category: testCategory,
                autofocus: false,
                onMove: (direction) {},
                onMoveEnd: () {},
              ),
            ),
          ),
        ),
      );

      // Wait for the FutureBuilder to complete
      await tester.pump();

      // Since we provided valid image data, the banner should be displayed
      final appCardFinder = find.byType(AppCard);
      final imageFinder = find.descendant(
        of: appCardFinder,
        matching: find.byType(Ink),
      );
      expect(imageFinder, findsWidgets);
    });
  });
}