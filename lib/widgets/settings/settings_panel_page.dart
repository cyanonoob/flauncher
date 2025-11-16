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

import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/ensure_visible.dart';
import 'package:flauncher/widgets/glass_container.dart';
import 'package:flauncher/widgets/settings/applications_panel_page.dart';
import 'package:flauncher/widgets/settings/launcher_sections_panel_page.dart';
import 'package:flauncher/widgets/settings/date_time_format_dialog.dart';
import 'package:flauncher/widgets/settings/flauncher_about_dialog.dart';
import 'package:flauncher/widgets/settings/status_bar_panel_page.dart';
import 'package:flauncher/widgets/settings/wallpaper_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '/l10n/app_localizations.dart';
import '../color_helpers.dart';
import '../rounded_switch_list_tile.dart';
import 'back_button_actions.dart';

class SettingsPanelPage extends StatelessWidget {
  static const String routeName = "settings_panel";

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Consumer<SettingsService>(
        builder: (context, settingsService, __) => Column(children: [
              Text(localizations.settings,
                  style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(children: [
                EnsureVisible(
                  alignment: 0.5,
                  child: TextButton(
                    autofocus: true,
                    style: TextButton.styleFrom(
                      overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.apps),
                        Container(width: 8),
                        Text(localizations.applications,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    onPressed: () => Navigator.of(context)
                        .pushNamed(ApplicationsPanelPage.routeName),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category),
                      Container(width: 8),
                      Text(localizations.launcherSections,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(LauncherSectionsPanelPage.routeName),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wallpaper_outlined),
                      Container(width: 8),
                      Text(localizations.wallpaper,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(WallpaperPanelPage.routeName),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates),
                      Container(width: 8),
                      Text(localizations.statusBar,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(StatusBarPanelPage.routeName),
                ),
                const Divider(),
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.settings_outlined),
                      Container(width: 8),
                      Text(localizations.systemSettings,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  onPressed: () => context.read<AppsService>().openSettings(),
                ),
                const Divider(),
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range),
                      Container(width: 8),
                      Text(localizations.dateAndTimeFormat,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  onPressed: () async => await _dateTimeFormatDialog(context),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back),
                      Container(width: 8),
                      Text(localizations.backButtonAction,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  onPressed: () async => await _backButtonActionDialog(context),
                ),
                RoundedSwitchListTile(
                  value: settingsService.appHighlightAnimationEnabled,
                  onChanged: (value) =>
                      settingsService.setAppHighlightAnimationEnabled(value),
                  title: Text(localizations.appCardHighlightAnimation,
                      style: Theme.of(context).textTheme.bodyMedium),
                  secondary: Icon(Icons.filter_center_focus),
                ),

                RoundedSwitchListTile(
                  value: settingsService.appKeyClickEnabled,
                  onChanged: (value) =>
                      settingsService.setAppKeyClickEnabled(value),
                  title: Text(localizations.appKeyClick,
                      style: Theme.of(context).textTheme.bodyMedium),
                  secondary: Icon(Icons.notifications_active),
                ),
                RoundedSwitchListTile(
                    value: settingsService.showCategoryTitles,
                    onChanged: (value) =>
                        settingsService.setShowCategoryTitles(value),
                    title: Text(localizations.showCategoryTitles,
                        style: Theme.of(context).textTheme.bodyMedium),
                    secondary: Icon(Icons.abc)),
                RoundedSwitchListTile(
                  value: settingsService.panelTransparencyEnabled,
                  onChanged: (value) =>
                      settingsService.setPanelTransparencyEnabled(value),
                  title: Text('Panel Transparency',
                      style: Theme.of(context).textTheme.bodyMedium),
                  secondary: Icon(Icons.layers),
                ),
                if (settingsService.panelTransparencyEnabled)
                  RoundedSwitchListTile(
                    value: settingsService.glassEffectsEnabled,
                    onChanged: (value) =>
                        settingsService.setGlassEffectsEnabled(value),
                    title: Text('Glass Effects',
                        style: Theme.of(context).textTheme.bodyMedium),
                    secondary: Icon(Icons.blur_on),
                  ),
                if (settingsService.panelTransparencyEnabled && 
                    settingsService.glassEffectsEnabled)
                  RoundedSwitchListTile(
                    value: settingsService.highQualityEffects,
                    onChanged: (value) =>
                        settingsService.setHighQualityEffects(value),
                    title: Text('High Quality Effects',
                        style: Theme.of(context).textTheme.bodyMedium),
                    secondary: Icon(Icons.high_quality),
                  ),
                const Divider(),
                TextButton(
                    style: TextButton.styleFrom(
                      overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline),
                        Container(width: 8),
                        Text(localizations.aboutFlauncher,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (_) => FutureBuilder<PackageInfo>(
                              future: PackageInfo.fromPlatform(),
                              builder: (context, snapshot) =>
                                  snapshot.connectionState ==
                                          ConnectionState.done
                                      ? FLauncherAboutDialog(
                                          packageInfo: snapshot.data!)
                                      : Container(),
                            )))
              ])))
            ]));
  }

  Future<void> _backButtonActionDialog(BuildContext context) async {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    SettingsService service = context.read<SettingsService>();

    final newAction = await showDialog<String>(
        context: context,
        builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 320),
                    child: IntrinsicHeight(
                      child: IntrinsicWidth(
                        child: GlassContainer(
                          blur: 12.0,
                          opacity: 0.65,
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.all(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.dialogTitleBackButtonAction,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              autofocus: true,
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              onPressed: () => Navigator.pop(context, ""),
                              child: Text(
                                localizations.dialogOptionBackButtonActionDoNothing,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              onPressed: () => Navigator.pop(context, BACK_BUTTON_ACTION_CLOCK),
                              child: Text(
                                localizations.dialogOptionBackButtonActionShowClock,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              onPressed: () => Navigator.pop(context, BACK_BUTTON_ACTION_SCREENSAVER),
                              child: Text(
                                localizations.dialogOptionBackButtonActionShowScreensaver,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ));

    if (newAction != null) {
      await service.setBackButtonAction(newAction);
    }
  }

  Future<void> _dateTimeFormatDialog(BuildContext context) async {
    SettingsService service = context.read<SettingsService>();

    final formatTuple = await showDialog<Tuple2<String, String>>(
        context: context,
        builder: (_) =>
            DateTimeFormatDialog(service.dateFormat, service.timeFormat));

    if (formatTuple != null) {
      await service.setDateTimeFormat(formatTuple.item1, formatTuple.item2);
    }
  }
}
