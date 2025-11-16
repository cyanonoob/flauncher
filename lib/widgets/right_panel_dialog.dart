/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flauncher/actions.dart';
import 'package:flutter/material.dart';
import 'glass_container.dart';

class RightPanelDialog extends StatelessWidget {
  final Widget child;
  final double width;

  const RightPanelDialog({
    required this.child,
    this.width = 250,
  });

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width - width - 16,
          right: 16,
          top: 16,
          bottom: 16,
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: GlassContainer(
          blur: 12.0,
          opacity: 0.48,
          borderRadius: BorderRadius.circular(16),
          padding: EdgeInsets.zero,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Actions(
                  actions: {BackIntent: BackAction(context)}, child: child),
            ),
          ),
        ),
      );
}
