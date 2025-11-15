import 'package:flutter/material.dart';

import 'settings/settings_panel.dart';

class SettingsIconButton extends StatelessWidget {
  const SettingsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IconButton(
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(),
        splashRadius: 24,
        icon: Icon(
          Icons.settings_outlined,
          color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.75),
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
          size: 20,
        ),
        onPressed: () => showDialog(
            context: context, builder: (_) => const SettingsPanel()),
        focusColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      ),
    );
  }
}
