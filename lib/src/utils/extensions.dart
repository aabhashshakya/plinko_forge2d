///Created by Aabhash Shakya on 10/21/24
import 'package:flame/components.dart';
import 'package:plinko_forge2d/config.dart';

extension Precision on double {
  //set the precision for a double
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

extension Scaled on Vector2 {
  Vector2 zoomAdapted([double scale = zoom]) => this..scale(1/scale);
}
