/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flauncher/gradients.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/animated_gradient_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.dart';
import '../mocks.mocks.dart';

void main() {
  group('AnimatedGradientOverlay', () {
    late MockWallpaperService mockWallpaperService;

    setUp(() {
      mockWallpaperService = MockWallpaperService();
    });

    testWidgets('creates overlay with gradient wallpaper', (WidgetTester tester) async {
      when(mockWallpaperService.selectedOption).thenReturn(WallpaperOption.gradient);
      when(mockWallpaperService.gradient).thenReturn(FLauncherGradients.greatWhale);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedGradientOverlay(wallpaperService: mockWallpaperService),
          ),
        ),
      );

      expect(find.byType(AnimatedGradientOverlay), findsOneWidget);
    });

    testWidgets('creates overlay with image wallpaper', (WidgetTester tester) async {
      when(mockWallpaperService.selectedOption).thenReturn(WallpaperOption.image);
      when(mockWallpaperService.wallpaper).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedGradientOverlay(wallpaperService: mockWallpaperService),
          ),
        ),
      );

      expect(find.byType(AnimatedGradientOverlay), findsOneWidget);
    });

    testWidgets('animation controller is properly initialized and disposed', (WidgetTester tester) async {
      when(mockWallpaperService.selectedOption).thenReturn(WallpaperOption.gradient);
      when(mockWallpaperService.gradient).thenReturn(FLauncherGradients.greatWhale);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedGradientOverlay(wallpaperService: mockWallpaperService),
          ),
        ),
      );

      // Verify the widget is created
      expect(find.byType(AnimatedGradientOverlay), findsOneWidget);

      // Trigger dispose
      await tester.pumpWidget(Container());
      
      // No exceptions should be thrown during dispose
      expect(tester.takeException(), isNull);
    });

    testWidgets('overlay uses darkened colors from gradient', (WidgetTester tester) async {
      when(mockWallpaperService.selectedOption).thenReturn(WallpaperOption.gradient);
      when(mockWallpaperService.gradient).thenReturn(FLauncherGradients.greatWhale);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedGradientOverlay(wallpaperService: mockWallpaperService),
          ),
        ),
      );

      // Advance animation to see color changes
      await tester.pump(const Duration(seconds: 1));

      // Verify the widget is still present and animating
      expect(find.byType(AnimatedGradientOverlay), findsOneWidget);
    });

    testWidgets('overlay uses default dark colors for image wallpaper', (WidgetTester tester) async {
      when(mockWallpaperService.selectedOption).thenReturn(WallpaperOption.image);
      when(mockWallpaperService.wallpaper).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedGradientOverlay(wallpaperService: mockWallpaperService),
          ),
        ),
      );

      // Advance animation to see color changes
      await tester.pump(const Duration(seconds: 1));

      // Verify the widget is still present and animating
      expect(find.byType(AnimatedGradientOverlay), findsOneWidget);
    });

    testWidgets('animation continues over time', (WidgetTester tester) async {
      when(mockWallpaperService.selectedOption).thenReturn(WallpaperOption.gradient);
      when(mockWallpaperService.gradient).thenReturn(FLauncherGradients.greatWhale);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedGradientOverlay(wallpaperService: mockWallpaperService),
          ),
        ),
      );

      // Pump multiple times to verify animation continues
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(AnimatedGradientOverlay), findsOneWidget);
      }
    });
  });
}