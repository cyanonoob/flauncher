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
import 'package:flauncher/widgets/app_card.dart';
import 'package:flauncher/widgets/category_container_common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app.dart';
import '../models/category.dart';
import '../providers/settings_service.dart';
import 'shadow_helpers.dart';

class CategoryRow extends StatefulWidget
{
  final Category category;
  final List<App> applications;

  CategoryRow({
    Key? key,
    required this.category,
    required this.applications,
  }) : super(key: key);

  @override
  State<CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  late List<Shadow> _primaryTextShadows;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _primaryTextShadows = PremiumShadows.primaryTextShadow(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget categoryContent;
    if (widget.applications.isEmpty) {
      categoryContent = categoryContainerEmptyState(context);
    }
    else {
      categoryContent = SizedBox(
        height: widget.category.rowHeight.toDouble(),
        child: ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.0, 0.08, 0.92, 1.0],
            colors: [
              Colors.white.withValues(alpha: 0.0),  // Left edge: Transparent
              Colors.white,                    // Start content: Full opacity
              Colors.white,                    // End content: Full opacity
              Colors.white.withValues(alpha: 0.0),  // Right edge: Transparent
            ],
          ).createShader(rect),
          blendMode: BlendMode.modulate,
          child: ListView.custom(
            padding: const EdgeInsets.only(left: 32, top: 8, right: 24, bottom: 40),
            scrollDirection: Axis.horizontal,
            childrenDelegate: SliverChildBuilderDelegate(
              childCount: widget.applications.length,
              findChildIndexCallback: _findChildIndex,
              (context, index) => AppCard(
                  key: Key(widget.applications[index].packageName),
                    category: widget.category,
                    application: widget.applications[index],
                    autofocus: index == 0,
                    onMove: (direction) => _onMove(context, direction, index),
                    onMoveEnd: () => _onMoveEnd(context)
                  )
            )
          )
        )
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Selector<SettingsService, bool>(
          selector: (context, service) => service.showCategoryTitles,
          builder: (context, showCategoriesTitle, _) {
            if (showCategoriesTitle) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(widget.category.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        shadows: _primaryTextShadows
                      )
                ),
              );
            }

            return SizedBox.shrink();
          }
        ),
        categoryContent
      ],
    );
  }

  int _findChildIndex(Key key) =>
      widget.applications.indexWhere((app) => app.packageName == (key as ValueKey<String>).value);

  void _onMove(BuildContext context, AxisDirection direction, int index) {
    int newIndex = 0;

    if (direction == AxisDirection.right && index < widget.applications.length - 1) {
      newIndex = index + 1;
    } else if (direction == AxisDirection.left && index > 0) {
      newIndex = index - 1;
    } else {
      return;
    }

    final appsService = context.read<AppsService>();
    appsService.reorderApplication(widget.category, index, newIndex);
  }

  void _onMoveEnd(BuildContext context) {
    final appsService = context.read<AppsService>();
    appsService.saveApplicationOrderInCategory(widget.category);
  }
}
