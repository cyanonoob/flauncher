import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/providers/media_service.dart';
import 'package:flauncher/widgets/shadow_helpers.dart';

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
            // Play/Pause button
            IconButton(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              splashRadius: 24,
              icon: Icon(
                session.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.85),
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
                size: 20,
              ),
              onPressed: () => mediaService.togglePlayPause(),
              focusColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 8),
            // Track info
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