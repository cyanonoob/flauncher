import 'package:flauncher/widgets/premium_button.dart';
import 'package:flutter/material.dart';

import 'settings/settings_panel.dart';

class SettingsIconButton extends StatelessWidget {
  const SettingsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: PremiumButton(
        padding: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(24),
        onPressed: () => showDialog(
            context: context, builder: (_) => const SettingsPanel()),
        child: Icon(
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
      ),
    );
  }
}
