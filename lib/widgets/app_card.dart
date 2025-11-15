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
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/application_info_panel.dart';
import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flauncher/widgets/shadow_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../models/app.dart';
import '../models/category.dart';

const _validationKeys = [
  LogicalKeyboardKey.select,
  LogicalKeyboardKey.enter,
  LogicalKeyboardKey.gameButtonA
];

class AppCard extends StatefulWidget {
  final App application;
  final Category category;
  final bool autofocus;
  final void Function(AxisDirection) onMove;
  final VoidCallback onMoveEnd;

  const AppCard({
    super.key,
    required this.application,
    required this.category,
    required this.autofocus,
    required this.onMove,
    required this.onMoveEnd,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

const int animationDuration = 1500;
const int animationMidStop = 150;
const int animationEndStop = 800;

class _AppCardState extends State<AppCard> with TickerProviderStateMixin {
  bool _moving = false;
  late List<BoxShadow> _baseFocusedShadows;
  FocusNode? _lastFocusedNode;

  late Future<Tuple2<AppImageType, ImageProvider>> _appImageLoadFuture;
  late final AnimationController _animation = AnimationController(
    vsync: this,
    lowerBound: 0,
    upperBound: 1,
    duration: const Duration(
      milliseconds: animationDuration,
    ),
  );

  // New dual animation controllers
  late final AnimationController _focusController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );

  late final AnimationController _glowController = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  );

  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 1.0, 
    end: 1.05,
  ).animate(CurvedAnimation(parent: _focusController, curve: Curves.easeOutCubic));

  late final Animation<double> _glowAnimation = Tween<double>(
    begin: 0.3, 
    end: 0.8,
  ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

  late final Animation<double> _borderAnimation = Tween<double>(
    begin: 0.0, 
    end: 1.0,
  ).animate(CurvedAnimation(parent: _focusController, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();

    FocusManager.instance.addHighlightModeListener(_focusHighlightModeChanged);
    _appImageLoadFuture =
        _loadAppBannerOrIcon(Provider.of<AppsService>(context, listen: false));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-compute shadows once when theme changes
    _baseFocusedShadows = PremiumShadows.focusedCardShadow(context);
  }

  @override
  void dispose() {
    FocusManager.instance
        .removeHighlightModeListener(_focusHighlightModeChanged);
    _animation.dispose();
    _focusController.dispose();
    _glowController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FocusKeyboardListener(
        onPressed: (key) => _onPressed(context, key),
        onLongPress: (key) => _onLongPress(context, key),
        builder: (context) {
          final bool shouldHighlight = _shouldHighlight(context);

          return RepaintBoundary(
            child: AnimatedPadding(
              padding: EdgeInsets.symmetric(horizontal: shouldHighlight ? 16 : 6),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_focusController, _glowController]),
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: shouldHighlight ? Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(
                            alpha: _borderAnimation.value * 0.6
                          ),
                          width: 2.0,
                        ) : null,
                        boxShadow: shouldHighlight 
                          ? _buildAnimatedFocusedShadows(context)
                          : PremiumShadows.cardShadow(context),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Material(
                        color: Colors.transparent,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            InkWell(
                              autofocus: widget.autofocus,
                              focusColor: Colors.transparent,
                              child: _appImage(),
                              onTap: () =>
                                  _onPressed(context, LogicalKeyboardKey.enter),
                              onLongPress: () =>
                                  _onLongPress(context, LogicalKeyboardKey.enter),
                              onFocusChange: (focused) {
                                if (focused) {
                                  _focusController.forward();
                                  _glowController.repeat(reverse: true);
                                  
                                  final currentNode = Focus.of(context);
                                  bool shouldScroll = false;
                                  
                                  if (_lastFocusedNode != null) {
                                    final lastY = _lastFocusedNode!.rect.center.dy;
                                    final currentY = currentNode.rect.center.dy;
                                    
                                    if ((lastY - currentY).abs() > 50) {
                                      shouldScroll = true;
                                    } else {
                                      final renderObject = context.findRenderObject();
                                      if (renderObject != null && renderObject is RenderBox) {
                                        final viewport = RenderAbstractViewport.of(renderObject);
                                        final revealedOffset = viewport.getOffsetToReveal(renderObject, 0.5);
                                        shouldScroll = revealedOffset.offset.abs() > 10;
                                      }
                                    }
                                  } else {
                                    shouldScroll = true;
                                  }
                                  
                                  if (shouldScroll) {
                                    Scrollable.ensureVisible(context,
                                        alignment: 0.5,
                                        curve: Curves.easeOutCubic,
                                        duration: Duration(milliseconds: 250));
                                  }
                                  
                                  _lastFocusedNode = currentNode;
                                } else {
                                  _focusController.reverse();
                                  _glowController.stop();
                                  _glowController.reset();
                                }
                              },
                            ),
                            if (_moving) ..._arrows(),
                            IgnorePointer(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                                opacity: shouldHighlight ? 0 : 0.06,
                                child: Container(color: Colors.black87),
                              ),
                            ),
                            Selector<SettingsService, bool>(
                              selector: (_, settingsService) =>
                                  settingsService.appHighlightAnimationEnabled &&
                                  shouldHighlight,
                              builder: (context, highlight, _) {
                                bool _highlightAnimating = false;

                                void _startHighlightAnimation() async {
                                  if (!_highlightAnimating && mounted) {
                                    _highlightAnimating = true;

                                    while (mounted && _shouldHighlight(context)) {
                                      await _animation.forward();
                                      await Future.delayed(const Duration(
                                          milliseconds: animationMidStop));
                                      await _animation.reverse();
                                      await Future.delayed(const Duration(
                                          milliseconds: animationEndStop));
                                    }
                                    
                                    _highlightAnimating = false;
                                  }
                                }

                                if (highlight) {
                                  // _animation.repeat(reverse: true);
                                  _startHighlightAnimation();

                                  return AnimatedBuilder(
                                    animation: _glowController,
                                    builder: (context, child) => IgnorePointer(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: RadialGradient(
                                            center: Alignment.center,
                                            radius: 1.0,
                                            colors: [
                                              Theme.of(context).colorScheme.primary.withValues(
                                                alpha: _glowAnimation.value * 0.1
                                              ),
                                              Colors.transparent,
                                            ],
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
                  ),
                ),
                ),
              ),
            ),
          );
        },
      );

  Future<Tuple2<AppImageType, ImageProvider>> _loadAppBannerOrIcon(
      AppsService service) async {
    Uint8List bytes = Uint8List(0);

    bytes = await service.getAppBanner(widget.application.packageName);
    AppImageType type = AppImageType.Banner;

    if (bytes.isEmpty) {
      type = AppImageType.Icon;
      bytes = await service.getAppIcon(widget.application.packageName);
    }

    return Tuple2(type, MemoryImage(bytes));
  }

  Widget _appImage() {
    App app = widget.application;

    return FutureBuilder(
        future: _appImageLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Tuple2<AppImageType, ImageProvider> tuple = snapshot.data!;

            if (tuple.item1 == AppImageType.Banner) {
              return Ink.image(image: tuple.item2, fit: BoxFit.cover);
            } else {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Ink.image(
                        image: tuple.item2,
                        height: double.maxFinite,
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          app.name,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                  child: Text(
                app.name,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              )),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 8),
                  const Flexible(child: Text("Loading"))
                ],
              ),
            );
          }
        });
  }

  void _focusHighlightModeChanged(FocusHighlightMode mode) {
    setState(() {});
  }

  bool _shouldHighlight(BuildContext context) {
    return FocusManager.instance.highlightMode ==
            FocusHighlightMode.traditional &&
        Focus.of(context).hasFocus;
  }

  List<BoxShadow> _buildAnimatedFocusedShadows(BuildContext context) {
    final base = _baseFocusedShadows;
    return [
      BoxShadow(
        color: base[0].color.withValues(alpha: base[0].color.a * _scaleAnimation.value),
        blurRadius: base[0].blurRadius,
        offset: base[0].offset,
        spreadRadius: base[0].spreadRadius,
      ),
      BoxShadow(
        color: base[1].color.withValues(alpha: base[1].color.a * _scaleAnimation.value),
        blurRadius: base[1].blurRadius,
        offset: base[1].offset,
        spreadRadius: base[1].spreadRadius,
      ),
      BoxShadow(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: _glowAnimation.value * 0.3),
        blurRadius: 30 + (20 * _glowAnimation.value),
        offset: Offset.zero,
        spreadRadius: 2 * _glowAnimation.value,
      ),
    ];
  }

  

  List<Widget> _arrows() => [
        _arrow(Alignment.centerLeft, Icons.keyboard_arrow_left, () {
          widget.onMove(AxisDirection.left);
        }),
        _arrow(Alignment.topCenter, Icons.keyboard_arrow_up, () {
          widget.onMove(AxisDirection.up);
        }),
        _arrow(Alignment.bottomCenter, Icons.keyboard_arrow_down, () {
          widget.onMove(AxisDirection.down);
        }),
        _arrow(Alignment.centerRight, Icons.keyboard_arrow_right, () {
          widget.onMove(AxisDirection.right);
        })
      ];

  Widget _arrow(Alignment alignment, IconData icon, VoidCallback onTap) =>
      Align(
          alignment: alignment,
          child: Ink(
              decoration: ShapeDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  shape: CircleBorder()),
              child: SizedBox(
                  height: 36,
                  width: 36,
                  child: IconButton(
                      icon: Icon(icon, size: 24),
                      onPressed: onTap,
                      padding: EdgeInsets.all(0)))));

  KeyEventResult _onPressed(BuildContext context, LogicalKeyboardKey? key) {
    if (_moving) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          Scrollable.ensureVisible(context,
              alignment: 0.1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic));
      if (key == LogicalKeyboardKey.arrowLeft) {
        widget.onMove(AxisDirection.left);
      } else if (key == LogicalKeyboardKey.arrowUp) {
        widget.onMove(AxisDirection.up);
      } else if (key == LogicalKeyboardKey.arrowRight) {
        widget.onMove(AxisDirection.right);
      } else if (key == LogicalKeyboardKey.arrowDown) {
        widget.onMove(AxisDirection.down);
      } else if (_validationKeys.contains(key) ||
          key == LogicalKeyboardKey.escape) {
        setState(() => _moving = false);
        widget.onMoveEnd();
      } else {
        return KeyEventResult.ignored;
      }

      return KeyEventResult.handled;
    } else if (_validationKeys.contains(key)) {
      context.read<AppsService>().launchApp(widget.application);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onLongPress(BuildContext context, LogicalKeyboardKey? key) {
    if (!_moving && (key == null || longPressableKeys.contains(key))) {
      _showPanel(context);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _showPanel(BuildContext context) async {
    final result = await showDialog<ApplicationInfoPanelResult>(
      context: context,
      builder: (context) => ApplicationInfoPanel(
        category: widget.category,
        application: widget.application,
      ),
    );
    if (result == ApplicationInfoPanelResult.reorderApp) {
      setState(() => _moving = true);
    }
  }
}