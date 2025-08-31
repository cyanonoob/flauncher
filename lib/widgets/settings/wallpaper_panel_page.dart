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

import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/settings/gradient_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class WallpaperPanelPage extends StatefulWidget {
  static const String routeName = "wallpaper_panel";

  @override
  State<WallpaperPanelPage> createState() => _WallpaperPanelPageState();
}

class _WallpaperPanelPageState extends State<WallpaperPanelPage> {
  final TextEditingController _unsplashQueryController =
      TextEditingController();
  final FocusNode _queryFocusNode = FocusNode();
  final FocusNode _unsplashButtonFocusNode = FocusNode();
  bool _isLoadingUnsplash = false;

  @override
  void dispose() {
    _unsplashQueryController.dispose();
    _queryFocusNode.dispose();
    _unsplashButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return FocusTraversalGroup(
      child: Column(
        children: [
          Text(localizations.wallpaper,
              style: Theme.of(context).textTheme.titleLarge),
          Divider(),
          TextButton(
            autofocus: true,
            child: Row(
              children: [
                Icon(Icons.gradient),
                Container(width: 8),
                Text(localizations.gradient,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(GradientPanelPage.routeName),
          ),
          TextButton(
            child: Row(
              children: [
                Icon(Icons.insert_drive_file_outlined),
                Container(width: 8),
                Text(localizations.picture,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            onPressed: () async {
              try {
                await context.read<WallpaperService>().pickWallpaper();
              } on NoFileExplorerException {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 8),
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text(localizations.dialogTextNoFileExplorer)
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          Divider(),
          FocusTraversalOrder(
            order: NumericFocusOrder(1.0),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Focus(
                focusNode: _queryFocusNode,
                onKey: (FocusNode node, RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      node.unfocus();
                      FocusScope.of(context)
                          .requestFocus(_unsplashButtonFocusNode);
                      return KeyEventResult.handled;
                    }
                    // Optionally handle up/left/right if needed
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _unsplashQueryController,
                  decoration: InputDecoration(
                    labelText: "Unsplash Query (e.g. nature, mountains)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),
          FocusTraversalOrder(
            order: NumericFocusOrder(2.0),
            child: TextButton(
              focusNode: _unsplashButtonFocusNode,
              child: _isLoadingUnsplash
                  ? CircularProgressIndicator()
                  : Row(
                      children: [
                        Icon(Icons.photo_library),
                        Container(width: 8),
                        Text("Get Unsplash Wallpaper",
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
              onPressed: _isLoadingUnsplash
                  ? null
                  : () async {
                      setState(() {
                        _isLoadingUnsplash = true;
                      });
                      try {
                        await context
                            .read<WallpaperService>()
                            .fetchUnsplashWallpaper(
                              query:
                                  _unsplashQueryController.text.trim().isEmpty
                                      ? null
                                      : _unsplashQueryController.text.trim(),
                            );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Failed to fetch Unsplash wallpaper: $e"),
                          ),
                        );
                      } finally {
                        setState(() {
                          _isLoadingUnsplash = false;
                        });
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
