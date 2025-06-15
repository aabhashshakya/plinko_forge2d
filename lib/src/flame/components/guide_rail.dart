import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'collision_configs.dart';

enum GuideRailPosition { left, right }

class GuideRail extends BodyComponent with ContactCallbacks {
  final int index;
  final List<Vector2> points;
  final GuideRailPosition guideRailPosition;

  GuideRail({
    required this.index,
    required this.points,
    required this.guideRailPosition,}) : super(
            paint: Paint()
              ..color = Colors.transparent
              ..style = PaintingStyle.fill);

  @override
  Body createBody() {
    final shape = ChainShape()..createChain(points);

    final fixtureDef = FixtureDef(shape)
      ..friction = 0
      ..restitution = 0.7;

    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..userData = this;

    var filter = Filter()
      ..categoryBits = CategoryBits.guideRails
      //maskBits means collision will be only detected with these components
      ..maskBits = CategoryBits.ball;

    final body = world.createBody(bodyDef);
    body.createFixture(fixtureDef..filter = filter);

    return body;
  }

// @override
// void render(Canvas canvas) {
//   super.render(canvas);
//
//   final paint = Paint()
//     ..color = Colors.transparent
//     ..strokeWidth = 0.1
//     ..style = PaintingStyle.stroke;
//
//   // Draw the line between start and end, relative to body's position (which is 0,0 here)
//   canvas.drawLine(
//     Offset(start.x, start.y),
//     Offset(end.x, end.y),
//     paint,
//   );
// }
}
