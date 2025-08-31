import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
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

  @override
  void dispose() {
    _queryController.dispose();
    _queryFocusNode.dispose();
    _unsplashButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        labelText: "Unsplash Query (e.g. nature, mountains)",
                        border: OutlineInputBorder(),
                      ),
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
                          : Text("Get Unsplash Wallpaper"),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              try {
                                await context
                                    .read<WallpaperService>()
                                    .fetchUnsplashWallpaper(
                                      query:
                                          _queryController.text.trim().isEmpty
                                              ? null
                                              : _queryController.text.trim(),
                                    );
                                Navigator.of(context).pop();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Failed to fetch Unsplash wallpaper: $e"),
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
