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

import 'package:flauncher/flauncher_channel.dart';
import 'package:flutter/foundation.dart';

class MediaSessionInfo {
  final String? packageName;
  final String? appName;
  final String? title;
  final String? artist;
  final String? album;
  final bool isPlaying;
  final bool hasActiveSession;
  final int? position;
  final int? duration;
  final List<String> availableActions;

  const MediaSessionInfo({
    this.packageName,
    this.appName,
    this.title,
    this.artist,
    this.album,
    this.isPlaying = false,
    this.hasActiveSession = false,
    this.position,
    this.duration,
    this.availableActions = const [],
  });

  factory MediaSessionInfo.fromMap(Map<String, dynamic> data) {
    return MediaSessionInfo(
      packageName: data['packageName'],
      appName: data['appName'],
      title: data['title'],
      artist: data['artist'],
      album: data['album'],
      isPlaying: data['isPlaying'] ?? false,
      hasActiveSession: data['hasActiveSession'] ?? false,
      position: data['position'],
      duration: data['duration'],
      availableActions: List<String>.from(data['availableActions'] ?? []),
    );
  }

  MediaSessionInfo copyWith({
    String? packageName,
    String? appName,
    String? title,
    String? artist,
    String? album,
    bool? isPlaying,
    bool? hasActiveSession,
    int? position,
    int? duration,
    List<String>? availableActions,
  }) {
    return MediaSessionInfo(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      isPlaying: isPlaying ?? this.isPlaying,
      hasActiveSession: hasActiveSession ?? this.hasActiveSession,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      availableActions: availableActions ?? this.availableActions,
    );
  }

  bool get canPlay => availableActions.contains('play');
  bool get canPause => availableActions.contains('pause');
  bool get canSkipNext => availableActions.contains('skipToNext');
  bool get canSkipPrevious => availableActions.contains('skipToPrevious');
  bool get canSeek => availableActions.contains('seekTo');

  @override
  String toString() {
    return 'MediaSessionInfo(packageName: $packageName, appName: $appName, title: $title, artist: $artist, isPlaying: $isPlaying, hasActiveSession: $hasActiveSession)';
  }
}

class MediaService extends ChangeNotifier {
  final FLauncherChannel _fLauncherChannel;

  MediaSessionInfo _currentSession = const MediaSessionInfo();
  Timer? _positionUpdateTimer;
  Timer? _pollingTimer;
  bool _initialized = false;
  bool _isVisible = true;

  MediaSessionInfo get currentSession => _currentSession;
  bool get hasActiveMedia => _currentSession.hasActiveSession;
  bool get initialized => _initialized;

  MediaService(this._fLauncherChannel) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Get initial media session state
      await _refreshMediaSession();

      // Listen for media session changes
      _fLauncherChannel.addMediaSessionListener(_onMediaSessionChanged);

      // Listen for visibility changes from platform
      _fLauncherChannel.addVisibilityListener(setVisibility);

      // Start position update timer for playing media
      _startPositionUpdates();

      // Start periodic polling for session detection
      _startPolling();

      _initialized = true;
      notifyListeners();
    } catch (e) {
      // Initialization failed
    }
  }

  Future<void> _refreshMediaSession() async {
    try {
      final sessionData = await _fLauncherChannel.getCurrentMediaSession();
      if (sessionData != null) {
        final newSession = MediaSessionInfo.fromMap(sessionData);
        _currentSession = newSession;
      } else {
        _currentSession = const MediaSessionInfo();
      }
      notifyListeners();
    } catch (e) {
      // Failed to refresh media session
    }
  }

  void _onMediaSessionChanged(Map<String, dynamic> data) {
    try {
      final newSession = MediaSessionInfo.fromMap(data);

      // Check if this is a meaningful change
      if (_currentSession.packageName != newSession.packageName ||
          _currentSession.isPlaying != newSession.isPlaying ||
          _currentSession.title != newSession.title ||
          _currentSession.hasActiveSession != newSession.hasActiveSession) {
        _currentSession = newSession;
        notifyListeners();

        // Update position timer based on playback state
        if (newSession.isPlaying) {
          _startPositionUpdates();
        } else {
          _stopPositionUpdates();
        }
      }
    } catch (e) {
      // Failed to process media session change
    }
  }

  void _startPositionUpdates() {
    _stopPositionUpdates();

    if (_currentSession.isPlaying && _currentSession.duration != null) {
      _positionUpdateTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _updatePosition(),
      );
    }
  }

  void _stopPositionUpdates() {
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = null;
  }

  void _updatePosition() {
    if (_currentSession.position != null && _currentSession.duration != null) {
      final newPosition = (_currentSession.position! + 1000)
          .clamp(0, _currentSession.duration!);

      _currentSession = _currentSession.copyWith(position: newPosition);
      notifyListeners();
    }
  }

  void _startPolling() {
    _stopPolling();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (_isVisible) {
          _refreshMediaSession();
        }
      },
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void setVisibility(bool visible) {
    if (_isVisible != visible) {
      _isVisible = visible;
      
      if (visible) {
        // Immediately refresh when becoming visible
        _refreshMediaSession();
      }
    }
  }

  // Media control methods
  Future<void> togglePlayPause() async {
    try {
      if (_currentSession.isPlaying) {
        await pause();
      } else {
        await play();
      }
    } catch (e) {
      // Failed to toggle play/pause
    }
  }

  Future<void> play() async {
    try {
      if (_currentSession.canPlay) {
        await _fLauncherChannel.sendPlay();
      }
    } catch (e) {
      // Failed to send play command
    }
  }

  Future<void> pause() async {
    try {
      if (_currentSession.canPause) {
        await _fLauncherChannel.sendPause();
      }
    } catch (e) {
      // Failed to send pause command
    }
  }

  Future<void> skipToNext() async {
    try {
      if (_currentSession.canSkipNext) {
        await _fLauncherChannel.sendSkipToNext();
      }
    } catch (e) {
      // Failed to send skip next command
    }
  }

  Future<void> skipToPrevious() async {
    try {
      if (_currentSession.canSkipPrevious) {
        await _fLauncherChannel.sendSkipToPrevious();
      }
    } catch (e) {
      // Failed to send skip previous command
    }
  }

  Future<void> sendCustomAction(String action) async {
    try {
      await _fLauncherChannel.sendMediaAction(action);
    } catch (e) {
      // Failed to send custom media action
    }
  }

  @override
  void dispose() {
    _stopPositionUpdates();
    _stopPolling();
    super.dispose();
  }
}
