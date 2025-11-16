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

import 'package:flauncher/providers/apps_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/l10n/app_localizations.dart';
import '../models/app.dart';
import '../models/category.dart';
import 'dart:ui';

class AddToCategoryDialog extends StatelessWidget {
  final App selectedApplication;

  AddToCategoryDialog(this.selectedApplication);

  @override
  Widget build(BuildContext context) => Selector<AppsService, List<Category>>(
        selector: (_, appsService) => appsService.categories
            .where((category) => !category.applications.any((application) =>
                application.packageName == selectedApplication.packageName))
            .toList(),
        builder: (context, categories, _) {
          AppLocalizations localizations = AppLocalizations.of(context)!;

          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 16),
                        child: Text(
                          localizations.withEllipsisAddTo,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      ...categories
                          .map(
                            (category) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                  width: 1.0,
                                ),
                              ),
                              child: ListTile(
                                onTap: () async {
                                  await context
                                      .read<AppsService>()
                                      .addToCategory(selectedApplication, category);
                                  Navigator.of(context).pop();
                                },
                                title: Text(category.name),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}
