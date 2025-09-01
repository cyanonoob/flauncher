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

import 'dart:async';

import 'package:flutter/services.dart';

class FLauncherChannel {
  static const _methodChannel = MethodChannel('com.geert.flauncher/method');
  static const _appsEventChannel =
      EventChannel('com.geert.flauncher/event_apps');
  static const _networkEventChannel =
      EventChannel('com.geert.flauncher/event_network');
  static const _mediaEventChannel =
      EventChannel('com.geert.flauncher/event_media');

  Future<List<Map<dynamic, dynamic>>> getApplications() async {
    List<Map<dynamic, dynamic>>? applications =
        await _methodChannel.invokeListMethod("getApplications");
    return applications!;
  }

  Future<Uint8List> getApplicationBanner(String packageName) async {
    Uint8List bytes =
        await _methodChannel.invokeMethod("getApplicationBanner", packageName);
    return bytes;
  }

  Future<Uint8List> getApplicationIcon(String packageName) async {
    Uint8List bytes =
        await _methodChannel.invokeMethod("getApplicationIcon", packageName);
    return bytes;
  }

  Future<bool> applicationExists(String packageName) async =>
      await _methodChannel.invokeMethod('applicationExists', packageName);

  Future<void> launchActivityFromAction(String action) async =>
      await _methodChannel.invokeMethod('launchActivityFromAction', action);

  Future<void> launchApp(String packageName) async =>
      await _methodChannel.invokeMethod('launchApp', packageName);

  Future<void> openSettings() async =>
      await _methodChannel.invokeMethod('openSettings');

  Future<void> openAppInfo(String packageName) async =>
      await _methodChannel.invokeMethod('openAppInfo', packageName);

  Future<void> uninstallApp(String packageName) async =>
      await _methodChannel.invokeMethod('uninstallApp', packageName);

  Future<bool> isDefaultLauncher() async =>
      await _methodChannel.invokeMethod('isDefaultLauncher');

  Future<bool> checkForGetContentAvailability() async =>
      await _methodChannel.invokeMethod("checkForGetContentAvailability");

  Future<Map<String, dynamic>> getActiveNetworkInformation() async {
    Map<dynamic, dynamic> map =
        await _methodChannel.invokeMethod("getActiveNetworkInformation");
    return map.cast<String, dynamic>();
  }

  Future<void> startAmbientMode() async =>
      await _methodChannel.invokeMethod("startAmbientMode");

  // Media Session methods
  Future<Map<String, dynamic>?> getCurrentMediaSession() async {
    try {
      Map<dynamic, dynamic>? result =
          await _methodChannel.invokeMethod("getCurrentMediaSession");
      return result?.cast<String, dynamic>();
    } catch (e) {
      return null;
    }
  }

  Future<void> sendMediaAction(String action) async =>
      await _methodChannel.invokeMethod("sendMediaAction", action);

  Future<void> sendPlayPause() async =>
      await _methodChannel.invokeMethod("sendPlayPause");

  Future<void> sendPlay() async =>
      await _methodChannel.invokeMethod("sendPlay");

  Future<void> sendPause() async =>
      await _methodChannel.invokeMethod("sendPause");

  Future<void> sendSkipToNext() async =>
      await _methodChannel.invokeMethod("sendSkipToNext");

  Future<void> sendSkipToPrevious() async =>
      await _methodChannel.invokeMethod("sendSkipToPrevious");

  void addAppsChangedListener(void Function(Map<String, dynamic>) listener) =>
      _appsEventChannel.receiveBroadcastStream().listen((event) {
        Map<dynamic, dynamic> eventMap = event;
        listener(eventMap.cast<String, dynamic>());
      });

  void addNetworkChangedListener(
          void Function(Map<String, dynamic>) listener) =>
      _networkEventChannel.receiveBroadcastStream().listen((event) {
        Map<dynamic, dynamic> eventMap = event;
        listener(eventMap.cast<String, dynamic>());
      });

  void addMediaSessionListener(void Function(Map<String, dynamic>) listener) =>
      _mediaEventChannel.receiveBroadcastStream().listen((event) {
        Map<dynamic, dynamic> eventMap = event;
        listener(eventMap.cast<String, dynamic>());
      });
}
