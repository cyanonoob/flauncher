import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/settings/gradient_panel_page.dart';
import 'package:flauncher/widgets/settings/unsplash_panel_page.dart';
import 'package:flauncher/widgets/tv_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/l10n/app_localizations.dart';

class WallpaperPanelPage extends StatefulWidget {
  static const String routeName = "wallpaper_panel";

  @override
  State<WallpaperPanelPage> createState() => _WallpaperPanelPageState();
}

class _WallpaperPanelPageState extends State<WallpaperPanelPage> {
  WallpaperService? _wallpaperService;
  final FocusNode _sliderFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _wallpaperService ??= Provider.of<WallpaperService>(context);


  }

  void _openOptionScreen(BuildContext context, WallpaperOption option) {
    _wallpaperService?.setSelectedOption(option);
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
  void dispose() {
    _sliderFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    final wallpaperService = Provider.of<WallpaperService>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          localizations.wallpaper,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Divider(),
        ListTile(
          leading: Radio<WallpaperOption>(
            value: WallpaperOption.gradient,
            groupValue: wallpaperService.selectedOption,
            onChanged: (value) {
              wallpaperService.setSelectedOption(WallpaperOption.gradient);
            },
          ),
          title: Text(localizations.gradient),
          trailing: ElevatedButton(
            child: Text(localizations.pick),
            onPressed: () {
              _openOptionScreen(context, WallpaperOption.gradient);
            },
          ),
        ),
        ListTile(
          leading: Radio<WallpaperOption>(
            value: WallpaperOption.image,
            groupValue: wallpaperService.selectedOption,
            onChanged: (value) {
              wallpaperService.setSelectedOption(WallpaperOption.image);
            },
          ),
          title: Text(localizations.picture),
          trailing: ElevatedButton(
            child: Text(localizations.pick),
            onPressed: () {
              _openOptionScreen(context, WallpaperOption.image);
            },
          ),
        ),
        ListTile(
          leading: Radio<WallpaperOption>(
            value: WallpaperOption.unsplash,
            groupValue: wallpaperService.selectedOption,
            onChanged: (value) {
              wallpaperService.setSelectedOption(WallpaperOption.unsplash);
            },
          ),
          title: Text("Unsplash"),
          trailing: ElevatedButton(
            child: Text(localizations.pick),
            onPressed: () {
              _openOptionScreen(context, WallpaperOption.unsplash);
            },
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.wallpaperBrightness,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.brightness_2, size: 20),
                  Expanded(
                    child: TVSlider(
                      focusNode: _sliderFocusNode,
                      value: wallpaperService.brightness,
                      min: 0.0,
                      max: 2.0,
                      divisions: 20,
                      onChanged: (value) {
                        wallpaperService.setBrightness(value);
                      },
                    ),
                  ),
                  Icon(Icons.brightness_7, size: 20),
                ],
              ),
              Center(
                child: Text(
                  '${(wallpaperService.brightness * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


