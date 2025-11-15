/*
 * FLauncher
 * Copyright (C) 2024 Oscar Rojas
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

import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/l10n/app_localizations.dart';
import '../../providers/settings_service.dart';

class StatusBarPanelPage extends StatefulWidget {
  static const String routeName = "status_bar_panel";

  @override
  State<StatusBarPanelPage> createState() => _StatusBarPanelPageState();
}

class _StatusBarPanelPageState extends State<StatusBarPanelPage> {
  final FLauncherChannel _fLauncherChannel = FLauncherChannel();
  bool? _hasPermission;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    setState(() {
      _isCheckingPermission = true;
    });

    try {
      final hasPermission =
          await _fLauncherChannel.hasNotificationListenerPermission();
      setState(() {
        _hasPermission = hasPermission;
        _isCheckingPermission = false;
      });
    } catch (e) {
      setState(() {
        _hasPermission = false;
        _isCheckingPermission = false;
      });
    }
  }

  Future<void> _openPermissionSettings() async {
    try {
      await _fLauncherChannel.openNotificationListenerSettings();
      // Wait a moment for user to potentially grant permission, then refresh
      await Future.delayed(const Duration(seconds: 2));
      _checkPermission();
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    SettingsService settingsService = Provider.of(context);

    return Column(
      children: [
        Text(localizations.statusBar,
            style: Theme.of(context).textTheme.titleLarge),
        Divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoundedSwitchListTile(
                  autofocus: true,
                  value: settingsService.autoHideAppBarEnabled,
                  onChanged: (value) =>
                      settingsService.setAutoHideAppBarEnabled(value),
                  title: Text(localizations.autoHideAppBar,
                      style: Theme.of(context).textTheme.bodyMedium),
                  secondary: Icon(Icons.visibility_off_outlined),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(localizations.titleStatusBarSettingsPage,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                SizedBox(height: 8, width: 0),
                RoundedSwitchListTile(
                    value: settingsService.showDateInStatusBar,
                    onChanged: (value) =>
                        settingsService.setShowDateInStatusBar(value),
                    title: Text(localizations.date),
                    secondary: Icon(Icons.calendar_today_outlined)),
                RoundedSwitchListTile(
                    value: settingsService.showTimeInStatusBar,
                    onChanged: (value) =>
                        settingsService.setShowTimeInStatusBar(value),
                    title: Text(localizations.time),
                    secondary: Icon(Icons.watch_later_outlined)),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(localizations.mediaControls,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                SizedBox(height: 8, width: 0),
                RoundedSwitchListTile(
                    value: settingsService.showMediaInStatusBar,
                    onChanged: (value) =>
                        settingsService.setShowMediaInStatusBar(value),
                    title: Text(localizations.showNowPlayingInStatusBar),
                    secondary: Icon(Icons.music_note)),
                SizedBox(height: 16, width: 0),
                // Permission status card - only show if permission is not granted
                if (_hasPermission != true)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _isCheckingPermission
                        ? Center(child: CircularProgressIndicator())
                        : Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          localizations.mediaPermissionRequired,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localizations.mediaPermissionDescription,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _openPermissionSettings,
                                    icon: const Icon(Icons.settings, size: 18),
                                    label: Text(localizations.grantPermission),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localizations.mediaPermissionInstructions,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color
                                              ?.withValues(alpha: 0.7),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
