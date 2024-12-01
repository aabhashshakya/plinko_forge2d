///Created by Aabhash Shakya on 10/21/24
import 'dart:math';

import 'package:flame/components.dart';
import 'package:plinko_forge2d/src/constants/config.dart';

extension Precision on double {
  //set the precision for a double
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

extension Scaled on Vector2 {
  Vector2 zoomAdapted([double scale = zoom]) => this..scale(1/scale);
}

extension RandomRange on Random{
  int randomBetween(int min, int max) => min + nextInt((max+1) - min);
}