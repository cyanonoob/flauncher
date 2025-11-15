import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/providers/media_service.dart';
import 'package:flauncher/widgets/shadow_helpers.dart';

import 'media_control_button.dart';

class NowPlayingWidget extends StatelessWidget {
  const NowPlayingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaService>(
      builder: (context, mediaService, _) {
        if (!mediaService.hasActiveMedia) {
          return const SizedBox.shrink();
        }

        final session = mediaService.currentSession;
        final textShadows = PremiumShadows.textShadow(context);
        
        // Build track info text
        String trackInfo = '';
        if (session.artist != null && session.artist!.isNotEmpty) {
          trackInfo = session.artist!;
        }
        if (session.title != null && session.title!.isNotEmpty) {
          if (trackInfo.isNotEmpty) {
            trackInfo += ' - ';
          }
          trackInfo += session.title!;
        }
        if (trackInfo.isEmpty) {
          trackInfo = session.appName ?? 'Unknown Track';
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MediaControlButton(
              isPlaying: session.isPlaying,
              onPressed: () => mediaService.togglePlayPause(),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                trackInfo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.85),
                  shadows: textShadows,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}