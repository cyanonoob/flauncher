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

import 'dart:math';

import 'package:flutter/material.dart';

class FLauncherGradient {
  final String uuid;
  final String name;
  final Gradient gradient;

  FLauncherGradient(this.uuid, this.name, this.gradient);
}

mixin FLauncherGradients {
  static final greatWhale = FLauncherGradient(
    "8bbdc190-ff6c-496e-8033-3c217e78da36",
    "Great Whale",
    LinearGradient(colors: [Colors.blue[400]!, Colors.blue[200]!], transform: GradientRotation(5.6)),
  );
  static final viciousStance = FLauncherGradient(
    "e89f29f3-a0a3-4ee6-a363-5e9df2a124fd",
    "Vicious Stance",
    LinearGradient(colors: [Colors.blueGrey[900]!, Colors.blueGrey[700]!], transform: GradientRotation(1.6)),
  );
  static final teenNotebook = FLauncherGradient(
    "027e7848-104c-42eb-94ce-d25762d426c1",
    "Teen Notebook",
    LinearGradient(colors: [Colors.deepPurple[300]!, Colors.pink[200]!], transform: GradientRotation(pi / 2)),
  );
  static final oldHat = FLauncherGradient(
    "8458ae14-7a5a-461d-bb14-154a04a9f6d2",
    "Old Hat",
    RadialGradient(colors: [Colors.orange[300]!, Colors.orange[100]!]),
  );
  static final burningSprings = FLauncherGradient(
    "57801094-a300-4626-8512-ec366d7d9c59",
    "Burning Spring",
    RadialGradient(colors: [Colors.teal[300]!, Colors.cyan[400]!]),
  );
  static final desertHump = FLauncherGradient(
    "34acee0a-788f-41ea-8d3c-3b7c02ea7b52",
    "Desert Hump",
    LinearGradient(colors: [Colors.brown[300]!, Colors.brown[200]!], transform: GradientRotation(pi / 2)),
  );
  static final farawayRiver = FLauncherGradient(
    "7d34faa2-104a-49b7-bea5-ad48f4ccbd9c",
    "Faraway River",
    LinearGradient(colors: [Colors.deepPurple[500]!, Colors.cyan[300]!], transform: GradientRotation(7.5)),
  );
  static final saintPetersburg = FLauncherGradient(
    "1312c885-af8a-4904-a2cb-f3afa05cdd20",
    "Saint Petersburg",
    LinearGradient(colors: [Colors.grey[100]!, Colors.grey[300]!], transform: GradientRotation(7)),
  );
  static final africanField = FLauncherGradient(
    "7e1c12aa-3769-4474-957a-e08ef98a93c2",
    "African Field",
    LinearGradient(colors: [Colors.pink[400]!, Colors.orange[300]!], transform: GradientRotation(2.3)),
  );
  static final grassShampoo = FLauncherGradient(
    "b9041b0b-22e3-43a1-a323-3d851f20464d",
    "Grass Shampoo",
    LinearGradient(
      colors: [Colors.green[400]!, Colors.green[300]!, Colors.green[200]!],
      stops: [0, 0.47, 1],
      transform: GradientRotation(5.5),
    ),
  );

  static List<FLauncherGradient> get all => [
        greatWhale,
        viciousStance,
        teenNotebook,
        oldHat,
        burningSprings,
        desertHump,
        farawayRiver,
        saintPetersburg,
        africanField,
        grassShampoo,
      ];
}
