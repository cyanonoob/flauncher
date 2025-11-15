import 'dart:async';

import 'package:flauncher/widgets/settings/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_service.dart';
import 'date_time_widget.dart';
import 'network_widget.dart';
import 'now_playing_widget.dart';
import 'shadow_helpers.dart';

class FocusAwareAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  State<StatefulWidget> createState() {
    return _FocusAwareAppBarState();
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 36);
}

class _FocusAwareAppBarState extends State<FocusAwareAppBar> {
  bool focused = false;
  late List<Shadow> _textShadows;
  Timer? _debounceTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textShadows = PremiumShadows.textShadow(context);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => focused = hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsService, bool>(
        selector: (_, settings) => settings.autoHideAppBarEnabled,
        builder: (context, autoHide, widget) {
          if (autoHide) {
            return Focus(
                canRequestFocus: false,
                child: AnimatedContainer(
                    curve: Curves.decelerate,
                    duration: Duration(milliseconds: 250),
                    height: focused ? kToolbarHeight + 36 : 0,
                    child: widget!),
                onFocusChange: _onFocusChange);
          }

          return widget!;
        },
        child: AppBar(
          toolbarHeight: kToolbarHeight + 36,
          title: Padding(
            padding: const EdgeInsets.only(top: 36),
            child: Selector<
              SettingsService,
              ({
                bool showDateInStatusBar,
                bool showTimeInStatusBar,
                String dateFormat,
                String timeFormat
              })>(
            selector: (context, service) => (
              showDateInStatusBar: service.showDateInStatusBar,
              showTimeInStatusBar: service.showTimeInStatusBar,
              dateFormat: service.dateFormat,
              timeFormat: service.timeFormat
            ),
            builder: (context, dateTimeSettings, _) {
              return Padding(
          padding: const EdgeInsets.only(left: 38),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (dateTimeSettings.showDateInStatusBar)
                  Flexible(
                      child: DateTimeWidget(
                    dateTimeSettings.dateFormat,
                    key: const ValueKey('date'),
                    updateInterval: const Duration(minutes: 1),
                    textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.85),
                      shadows: _textShadows,
                    ),
                  )),
                if (dateTimeSettings.showTimeInStatusBar && dateTimeSettings.showDateInStatusBar)
                  const SizedBox(width: 8),
                if (dateTimeSettings.showTimeInStatusBar)
                  Flexible(
                      child: DateTimeWidget(dateTimeSettings.timeFormat,
                          key: const ValueKey('time'),
                          textStyle: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.85),
                                shadows: _textShadows,
                          ))),
              ]),
              );
            },
          ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 36),
              child: Row(
                children: [
                  Selector<SettingsService, bool>(
                    selector: (_, settings) => settings.showMediaInStatusBar,
                    builder: (context, showMedia, _) {
                      if (!showMedia) {
                        return const SizedBox.shrink();
                      }
                      return const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: NowPlayingWidget(),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: NetworkWidget(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 38),
                    child: RepaintBoundary(
                      child: IconButton(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        splashRadius: 24,
                        icon: Icon(
                          Icons.settings_outlined,
                          color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.75),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                          size: 20,
                        ),
                        onPressed: () => showDialog(
                            context: context, builder: (_) => const SettingsPanel()),
                        // sometime after Flutter 3.7.5, no later than 3.16.8, the focus highlight went away
                        focusColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
