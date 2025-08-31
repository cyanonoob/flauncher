import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/services.dart';

class UnsplashPanelPage extends StatefulWidget {
  @override
  State<UnsplashPanelPage> createState() => _UnsplashPanelPageState();
}

class _UnsplashPanelPageState extends State<UnsplashPanelPage> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocusNode = FocusNode();
  final FocusNode _unsplashButtonFocusNode = FocusNode();
  bool _isLoading = false;
  bool _ignoreTextFieldKeyEvent = false;

  @override
  void initState() {
    super.initState();
    // Restore persisted query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsService>(context, listen: false);
      _queryController.text = settings.unsplashQuery ?? '';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final FocusScopeNode focusScopeNode = FocusScope.of(context);
    focusScopeNode.onKeyEvent = (node, keyEvent) {
      if (_queryFocusNode.hasFocus &&
          (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp ||
              keyEvent.logicalKey == LogicalKeyboardKey.arrowDown)) {
        if (!_ignoreTextFieldKeyEvent) {
          if (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp) {
            _queryFocusNode.previousFocus();
          }
          if (keyEvent.logicalKey == LogicalKeyboardKey.arrowDown) {
            _queryFocusNode.nextFocus();
          }
        }

        _ignoreTextFieldKeyEvent = false;
      } else {
        _ignoreTextFieldKeyEvent = true;
      }

      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    _queryController.dispose();
    _queryFocusNode.dispose();
    _unsplashButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text("Unsplash", style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FocusTraversalGroup(
              child: Column(
                children: [
                  FocusTraversalOrder(
                    order: NumericFocusOrder(1.0),
                    child: TextField(
                      controller: _queryController,
                      focusNode: _queryFocusNode,
                      decoration: InputDecoration(
                        labelText: localizations.unsplashQueryLabel,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        Provider.of<SettingsService>(context, listen: false)
                            .setUnsplashQuery(value);
                      },
                      onEditingComplete: () {
                        FocusScope.of(context)
                            .requestFocus(_unsplashButtonFocusNode);
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  FocusTraversalOrder(
                    order: NumericFocusOrder(2.0),
                    child: ElevatedButton(
                      focusNode: _unsplashButtonFocusNode,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text(localizations.apply),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              final query = _queryController.text.trim();
                              await Provider.of<SettingsService>(context,
                                      listen: false)
                                  .setUnsplashQuery(query);
                              try {
                                await context
                                    .read<WallpaperService>()
                                    .fetchUnsplashWallpaper(
                                      query: query.isEmpty ? null : query,
                                    );
                                Navigator.of(context).pop();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(localizations
                                        .unsplashErrorMessage(e.toString())),
                                  ),
                                );
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
