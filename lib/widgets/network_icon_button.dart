import 'package:flutter/material.dart';

import '../flauncher_channel.dart';

class NetworkIconButton extends StatelessWidget {
  final IconData iconData;

  const NetworkIconButton({super.key, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IconButton(
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(),
        splashRadius: 24,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.focused)) {
              return Theme.of(context).colorScheme.primary.withValues(alpha: 0.4);
            }
            return null;
          }),
        ),
        icon: Icon(
          iconData,
          color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.75),
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
          size: 18,
        ),
        onPressed: () => FLauncherChannel().openWifiSettings(),
      ),
    );
  }
}
