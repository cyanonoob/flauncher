import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/settings/gradient_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// You need to create this page!
import 'unsplash_panel_page.dart';

enum WallpaperOption { gradient, image, unsplash }

class WallpaperPanelPage extends StatefulWidget {
  static const String routeName = "wallpaper_panel";

  @override
  State<WallpaperPanelPage> createState() => _WallpaperPanelPageState();
}

class _WallpaperPanelPageState extends State<WallpaperPanelPage> {
  WallpaperOption? _selectedOption = WallpaperOption.gradient;

  void _openOptionScreen(BuildContext context, WallpaperOption option) {
    switch (option) {
      case WallpaperOption.gradient:
        Navigator.of(context).pushNamed(GradientPanelPage.routeName);
        break;
      case WallpaperOption.image:
        _openImagePicker(context);
        break;
      case WallpaperOption.unsplash:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => UnsplashPanelPage()),
        );
        break;
    }
  }

  Future<void> _openImagePicker(BuildContext context) async {
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
              Text(AppLocalizations.of(context)!.dialogTextNoFileExplorer)
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.wallpaper,
            style: Theme.of(context).textTheme.titleLarge),
        Divider(),
        ListTile(
          leading: Radio<WallpaperOption>(
            value: WallpaperOption.gradient,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() => _selectedOption = value);
              _openOptionScreen(context, WallpaperOption.gradient);
            },
          ),
          title: Text(localizations.gradient),
          onTap: () {
            setState(() => _selectedOption = WallpaperOption.gradient);
            _openOptionScreen(context, WallpaperOption.gradient);
          },
        ),
        ListTile(
          leading: Radio<WallpaperOption>(
            value: WallpaperOption.image,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() => _selectedOption = value);
              _openOptionScreen(context, WallpaperOption.image);
            },
          ),
          title: Text(localizations.picture),
          onTap: () {
            setState(() => _selectedOption = WallpaperOption.image);
            _openOptionScreen(context, WallpaperOption.image);
          },
        ),
        ListTile(
          leading: Radio<WallpaperOption>(
            value: WallpaperOption.unsplash,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() => _selectedOption = value);
              _openOptionScreen(context, WallpaperOption.unsplash);
            },
          ),
          title: Text("Unsplash"),
          onTap: () {
            setState(() => _selectedOption = WallpaperOption.unsplash);
            _openOptionScreen(context, WallpaperOption.unsplash);
          },
        ),
      ],
    );
  }
}
