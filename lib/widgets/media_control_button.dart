import 'package:flauncher/widgets/premium_button.dart';
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
      child: PremiumButton(
        padding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(24),
        onPressed: onPressed,
        child: Icon(
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
      ),
    );
  }
}
