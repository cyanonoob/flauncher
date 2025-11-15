import 'package:flutter/material.dart';

class MediaControlButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const MediaControlButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IconButton(
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(),
        splashRadius: 24,
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
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
        onPressed: onPressed,
        focusColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
      ),
    );
  }
}
