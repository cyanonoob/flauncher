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

import 'package:flauncher/models/category.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/l10n/app_localizations.dart';
import '../color_helpers.dart';
import '/widgets/glass_container.dart';

class CategoryPanelPage extends StatefulWidget {
  final int categoryId;
  
  const CategoryPanelPage({required this.categoryId, Key? key}) : super(key: key);

  @override
  State<CategoryPanelPage> createState() => _CategoryPanelPageState();
}

class _CategoryPanelPageState extends State<CategoryPanelPage> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    final appsService = Provider.of<AppsService>(context);
    
    final category = appsService.categoriesWithApps
        .where((cwa) => cwa.category.id == widget.categoryId)
        .firstOrNull;
    
    if (category == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(localizations.category)),
        body: Center(child: Text('Category not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(category.category.name)),
      body: ListView(
        children: [
          ListTile(
            title: Text('Sort'),
            subtitle: Text(category.category.sort.name),
            onTap: () {
              // Show sort options
              _showSortOptions(context, appsService, category.category);
            },
          ),
          ListTile(
            title: Text('Type'),
            subtitle: Text(category.category.type.name),
            onTap: () {
              // Show type options
              _showTypeOptions(context, appsService, category.category);
            },
          ),
          if (category.category.type == CategoryType.grid)
            ListTile(
              title: Text('Columns Count'),
              subtitle: Text('${category.category.columnsCount}'),
              onTap: () {
                // Show columns count options
                _showColumnsOptions(context, appsService, category.category);
              },
            ),
          if (category.category.type == CategoryType.row)
            ListTile(
              title: Text('Row Height'),
              subtitle: Text('${category.category.rowHeight}'),
              onTap: () {
                // Show row height options
                _showRowHeightOptions(context, appsService, category.category);
              },
            ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, AppsService appsService, Category category) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350),
          child: GlassContainer(
            blur: 12.0,
            opacity: 0.65,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort Order',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        appsService.setCategorySort(category, CategorySort.manual);
                        Navigator.pop(context);
                      },
                      child: Text('Manual'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        appsService.setCategorySort(category, CategorySort.alphabetical);
                        Navigator.pop(context);
                      },
                      child: Text('Alphabetical'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTypeOptions(BuildContext context, AppsService appsService, Category category) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350),
          child: GlassContainer(
            blur: 12.0,
            opacity: 0.65,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Type',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        appsService.setCategoryType(category, CategoryType.row);
                        Navigator.pop(context);
                      },
                      child: Text('Row'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        appsService.setCategoryType(category, CategoryType.grid);
                        Navigator.pop(context);
                      },
                      child: Text('Grid'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showColumnsOptions(BuildContext context, AppsService appsService, Category category) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: GlassContainer(
            blur: 12.0,
            opacity: 0.65,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Columns Count',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [3, 4, 5, 6, 7, 8].map((columns) {
                    return TextButton(
                      onPressed: () {
                        appsService.setCategoryColumnsCount(category, columns);
                        Navigator.pop(context);
                      },
                      child: Text('$columns'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRowHeightOptions(BuildContext context, AppsService appsService, Category category) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: GlassContainer(
            blur: 12.0,
            opacity: 0.65,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Row Height',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [100, 110, 120, 130, 140, 150].map((height) {
                    return TextButton(
                      onPressed: () {
                        appsService.setCategoryRowHeight(category, height);
                        Navigator.pop(context);
                      },
                      child: Text('$height'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}