import 'package:flauncher/widgets/settings/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_service.dart';
import 'date_time_widget.dart';
import 'network_widget.dart';
import 'shadow_helpers.dart';

class FocusAwareAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  State<StatefulWidget> createState() {
    return _FocusAwareAppBarState();
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _FocusAwareAppBarState extends State<FocusAwareAppBar> {
  bool focused = false;
  late List<Shadow> _textShadows;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textShadows = PremiumShadows.textShadow(context);
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
                    height: focused ? kToolbarHeight : 0,
                    child: widget!),
                onFocusChange: (hasFocus) {
                  this.setState(() {
                    focused = hasFocus;
                  });
                });
          }

          return widget!;
        },
        child: AppBar(
          actions: [
            IconButton(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(),
              splashRadius: 20,
              color:
                  Theme.of(context).textTheme.titleMedium?.color,

              icon: Icon(
                Icons.settings_outlined,
                shadows: PremiumShadows.textShadow(context),
              ),
              onPressed: () => showDialog(
                  context: context, builder: (_) => const SettingsPanel()),
              // sometime after Flutter 3.7.5, no later than 3.16.8, the focus highlight went away
              focusColor: Colors.white.withOpacity(0.3),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: NetworkWidget(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 32),
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
                  return Row(mainAxisSize: MainAxisSize.min, children: [
                    if (dateTimeSettings.showDateInStatusBar)
                      Flexible(
                          child: DateTimeWidget(
                        dateTimeSettings.dateFormat,
                        key: const ValueKey('date'),
                        updateInterval: const Duration(minutes: 1),
                        textStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
shadows: _textShadows,
                        ),
                      )),
                    if (dateTimeSettings.showDateInStatusBar &&
                        dateTimeSettings.showTimeInStatusBar)
                      const SizedBox(width: 16),
                    if (dateTimeSettings.showTimeInStatusBar)
                      Flexible(
                          child: DateTimeWidget(dateTimeSettings.timeFormat,
                              key: const ValueKey('time'),
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
shadows: _textShadows,
                              )))
                  ]);
                },
              ),
            ),
          ],
        ));
  }
}
