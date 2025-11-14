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

import 'package:flauncher/actions.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'flauncher.dart';

class FLauncherApp extends StatelessWidget {
  static const PrioritizedIntents _backIntents =
      PrioritizedIntents(orderedIntents: [DismissIntent(), BackIntent()]);

  static const MaterialColor _swatch = MaterialColor(0xFF011526, <int, Color>{
    50: Color(0xFF4A9FFF),
    100: Color(0xFF1A7FE8),
    200: Color(0xFF0F5FC7),
    300: Color(0xFF08407A),
    400: Color(0xFF042A4F),
    500: Color(0xFF011526),
    600: Color(0xFF000A12),
    700: Color(0xFF000508),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  });

  static const Color _accentColor = Color(0xFF4A9FFF);
  static const Color _highlightColor = Color(0xFF6BB6FF);

  const FLauncherApp();

  @override
  Widget build(BuildContext context) {
    AppsService appsService = context.read<AppsService>();
    LauncherState launcherState = context.read<LauncherState>();
    launcherState.refresh(appsService);

    return MaterialApp(
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.escape): _backIntents,
        const SingleActivator(LogicalKeyboardKey.gameButtonB): _backIntents,
        const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent()
      },
      actions: {
        ...WidgetsApp.defaultActions,
        BackIntent: BackAction(context),
        DirectionalFocusIntent: SoundFeedbackDirectionalFocusAction(context)
      },
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'FLauncher',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: _swatch,
        cardColor: _swatch[500],
        canvasColor: _swatch[500],
        dialogBackgroundColor: _swatch[500],
        scaffoldBackgroundColor: _swatch[400],
        colorScheme: ColorScheme.dark(
          primary: _accentColor,
          secondary: _highlightColor,
          surface: _swatch[500]!,
          background: _swatch[400]!,
        ),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.white)),
        appBarTheme: const AppBarTheme(
            elevation: 0, backgroundColor: Colors.transparent),
        typography: Typography.material2018().copyWith(
          white: Typography.material2018().white.copyWith(
            displayLarge: const TextStyle(fontFamily: 'Poppins'),
            displayMedium: const TextStyle(fontFamily: 'Poppins'),
            displaySmall: const TextStyle(fontFamily: 'Poppins'),
            headlineLarge: const TextStyle(fontFamily: 'Poppins'),
            headlineMedium: const TextStyle(fontFamily: 'Poppins'),
            headlineSmall: const TextStyle(fontFamily: 'Poppins'),
            titleLarge: const TextStyle(fontFamily: 'Poppins'),
            titleMedium: const TextStyle(fontFamily: 'Poppins'),
            titleSmall: const TextStyle(fontFamily: 'Poppins'),
            bodyLarge: const TextStyle(fontFamily: 'Poppins'),
            bodyMedium: const TextStyle(fontFamily: 'Poppins'),
            bodySmall: const TextStyle(fontFamily: 'Poppins'),
            labelLarge: const TextStyle(fontFamily: 'Poppins'),
            labelMedium: const TextStyle(fontFamily: 'Poppins'),
            labelSmall: const TextStyle(fontFamily: 'Poppins'),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
          labelStyle: Typography.material2018().white.bodyMedium,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: _swatch[200],
          selectionHandleColor: _swatch[200],
        ),
        cardTheme: CardThemeData(
          color: _swatch[500],
          elevation: 0,
        ),
        listTileTheme: ListTileThemeData(
          tileColor: _swatch[500],
          selectedTileColor: _swatch[400],
        ),
      ),
      home: Builder(
          builder: (context) => PopScope(
              canPop: false,
              child: FLauncher(),
              onPopInvoked: (didPop) {
                LauncherState launcherState = context.read<LauncherState>();
                launcherState.handleBackNavigation(context);
              })),
    );
  }
}
