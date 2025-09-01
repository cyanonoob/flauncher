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

import 'package:flauncher/app_image_type.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/media_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../models/app.dart';

const _validationKeys = [
  LogicalKeyboardKey.select,
  LogicalKeyboardKey.enter,
  LogicalKeyboardKey.gameButtonA
];

class MediaControlCard extends StatefulWidget {
  final bool autofocus;

  const MediaControlCard({
    super.key,
    this.autofocus = false,
  });

  @override
  State<MediaControlCard> createState() => _MediaControlCardState();
}

class _MediaControlCardState extends State<MediaControlCard>
    with SingleTickerProviderStateMixin {
  late Future<Tuple2<AppImageType, ImageProvider>?> _appImageLoadFuture;
  late final AnimationController _animation = AnimationController(
    vsync: this,
    lowerBound: 0,
    upperBound: 1,
    duration: const Duration(milliseconds: 2400),
  );

  late final Animation<double> _curvedAnimation = CurvedAnimation(
    parent: _animation,
    curve: Curves.easeInOutSine,
  );

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_focusHighlightModeChanged);
    _loadAppIconWhenNeeded();
  }

  @override
  void dispose() {
    FocusManager.instance
        .removeHighlightModeListener(_focusHighlightModeChanged);
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaService>(
      builder: (context, mediaService, child) {
        if (!mediaService.hasActiveMedia) {
          return const SizedBox.shrink();
        }

        return FocusKeyboardListener(
          onPressed: (key) => _onPressed(context, key, mediaService),
          onLongPress: (key) => _onLongPress(context, key, mediaService),
          builder: (context) {
            final bool shouldHighlight = _shouldHighlight(context);

            return AspectRatio(
              aspectRatio: 16 / 9,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                transformAlignment: Alignment.center,
                transform: _scaleTransform(context),
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  elevation: shouldHighlight ? 16 : 0,
                  shadowColor: Colors.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      InkWell(
                        autofocus: widget.autofocus,
                        focusColor: Colors.transparent,
                        child: _buildMediaContent(mediaService.currentSession),
                        onTap: () => _onPressed(
                            context, LogicalKeyboardKey.enter, mediaService),
                        onLongPress: () => _onLongPress(
                            context, LogicalKeyboardKey.enter, mediaService),
                        onFocusChange: (focused) {
                          if (focused) {
                            _loadAppIconWhenNeeded(
                                mediaService.currentSession.packageName);
                          }
                          Scrollable.ensureVisible(
                            context,
                            alignment: 0.5,
                            curve: Curves.easeInOut,
                            duration: const Duration(milliseconds: 100),
                          );
                        },
                      ),
                      IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          opacity: shouldHighlight ? 0 : 0.10,
                          child: Container(color: Colors.black),
                        ),
                      ),
                      Selector<SettingsService, bool>(
                        selector: (_, settingsService) =>
                            settingsService.appHighlightAnimationEnabled &&
                            shouldHighlight,
                        builder: (context, highlight, _) {
                          bool _highlightAnimating = false;

                          void _startHighlightAnimation() async {
                            if (!_highlightAnimating) {
                              _highlightAnimating = true;

                              while (mounted && _shouldHighlight(context)) {
                                await _animation.forward();
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                                await _animation.reverse();
                                await Future.delayed(
                                    const Duration(milliseconds: 1200));
                              }
                            }
                          }

                          if (highlight) {
                            _startHighlightAnimation();

                            return AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) => IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(
                                            (_curvedAnimation.value * 51)
                                                .round()),
                                        blurRadius: 48,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(
                                          (55 + (_curvedAnimation.value * 200))
                                              .round()),
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          _animation.stop();
                          _highlightAnimating = false;

                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _loadAppIconWhenNeeded([String? packageName]) {
    if (packageName != null && packageName.isNotEmpty) {
      _appImageLoadFuture = _loadAppIcon(packageName);
    }
  }

  Future<Tuple2<AppImageType, ImageProvider>?> _loadAppIcon(
      String packageName) async {
    try {
      final appsService = Provider.of<AppsService>(context, listen: false);
      Uint8List bytes = await appsService.getAppIcon(packageName);

      if (bytes.isNotEmpty) {
        return Tuple2(AppImageType.Icon, MemoryImage(bytes));
      }
    } catch (e) {
      // Handle error - app might not be available
    }

    return null;
  }

  Widget _buildMediaContent(MediaSessionInfo session) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.withOpacity(0.8),
            Colors.purple.withOpacity(0.6),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // App icon
            Expanded(
              flex: 2,
              child: _buildAppIcon(),
            ),
            const SizedBox(width: 16),
            // Media info
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (session.title != null && session.title!.isNotEmpty)
                    Text(
                      session.title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  if (session.artist != null && session.artist!.isNotEmpty)
                    Text(
                      session.artist!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  if (session.appName != null && session.appName!.isNotEmpty)
                    Text(
                      session.appName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  // Show progress if available
                  if (session.duration != null && session.position != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: LinearProgressIndicator(
                        value: session.position! / session.duration!,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white70),
                        minHeight: 2,
                      ),
                    ),
                ],
              ),
            ),
            // Play/pause button
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    session.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return FutureBuilder<Tuple2<AppImageType, ImageProvider>?>(
      future: _appImageLoadFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: snapshot.data!.item2,
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.white,
              size: 32,
            ),
          );
        }
      },
    );
  }

  void _focusHighlightModeChanged(FocusHighlightMode mode) {
    setState(() {});
  }

  bool _shouldHighlight(BuildContext context) {
    return FocusManager.instance.highlightMode ==
            FocusHighlightMode.traditional &&
        Focus.of(context).hasFocus;
  }

  Matrix4 _scaleTransform(BuildContext context) {
    double scale = 1.0;
    if (_shouldHighlight(context)) {
      scale = 1.1;
    }
    return Matrix4.diagonal3Values(scale, scale, 1.0);
  }

  KeyEventResult _onPressed(BuildContext context, LogicalKeyboardKey? key,
      MediaService mediaService) {
    if (_validationKeys.contains(key)) {
      // Toggle play/pause
      mediaService.togglePlayPause();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onLongPress(BuildContext context, LogicalKeyboardKey? key,
      MediaService mediaService) {
    if (key == null || longPressableKeys.contains(key)) {
      // Open the media app
      _launchMediaApp(context, mediaService.currentSession);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _launchMediaApp(BuildContext context, MediaSessionInfo session) {
    if (session.packageName != null && session.packageName!.isNotEmpty) {
      final appsService = context.read<AppsService>();
      final app = appsService.applications.firstWhere(
        (app) => app.packageName == session.packageName,
        orElse: () => App(
          packageName: session.packageName!,
          name: session.appName ?? 'Media App',
          version: '1.0',
          hidden: false,
        ),
      );
      appsService.launchApp(app);
    }
  }
}

// TODO: Android MediaSession Integration
// The following Android-side implementation is required for full functionality:
//
// 1. Add to MainActivity.java:
//    - Import MediaSessionManager, MediaController, MediaMetadata
//    - Add media session listener registration
//    - Implement getCurrentMediaSession() method
//    - Implement sendPlayPause(), sendPlay(), sendPause() methods
//    - Implement sendSkipToNext(), sendSkipToPrevious() methods
//    - Add media event channel for real-time updates
//
// 2. Required Android permissions in AndroidManifest.xml:
//    - <uses-permission android:name="android.permission.MEDIA_CONTENT_CONTROL" />
//    - <uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />
//
// 3. MediaSession data structure should include:
//    - packageName: String (source app package)
//    - appName: String (human readable app name)
//    - title: String (track title)
//    - artist: String (track artist)
//    - album: String (album name)
//    - isPlaying: boolean (playback state)
//    - hasActiveSession: boolean (session availability)
//    - position: long (current position in ms)
//    - duration: long (track duration in ms)
//    - availableActions: List<String> (supported media actions)
//
// TODO: Render this media control card on the home screen
// - Should render before all currently displayed apps in a new row
// - Should not have move controls and other options that categorized app cards have
// - Should only render if media is active (paused also counts)
// - Add MediaService to app providers
