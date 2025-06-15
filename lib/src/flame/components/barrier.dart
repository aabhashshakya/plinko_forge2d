import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:plinko_forge2d/src/constants/config.dart';
import 'package:plinko_forge2d/src/flame/plinko_forge2d.dart';
import 'package:plinko_forge2d/src/utils/extensions.dart';

import 'collision_configs.dart';

//barrier in triangle shape to prevent ball going out
class Barrier extends BodyComponent with ContactCallbacks {
  final List<Vector2> points;

  Barrier({required this.points})
      : super(
            paint: Paint()
              ..color = Colors.transparent
              ..style = PaintingStyle.fill);

  @override
  Body createBody() {
    final shape = ChainShape()..createChain(points);

    final fixtureDef = FixtureDef(shape)
      ..friction = 0.5
      ..restitution = 0.7;

    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..userData = this;

    var filter = Filter()
      ..categoryBits = CategoryBits.wall
      //maskBits means collision will be only detected with these components
      ..maskBits = CategoryBits.ball;

    final body = world.createBody(bodyDef);
    body.createFixture(fixtureDef..filter = filter);

    return body;
  }
}

void createBarrier(Plinko plinko) {
  //set a color to the barrier to see how these are drawn
  var obstacleHelper = plinko.obstacleHelper;
  var topLeftObstacle = obstacleHelper.getObstaclePosition(0, 0);
  var bottomLeftObstacle =
      obstacleHelper.getObstaclePosition(obstacleRows - 1, 0);

  plinko.world.add(Barrier(points: [
    topLeftObstacle!.translated(0,-100).zoomAdapted(),
    topLeftObstacle!,
    bottomLeftObstacle!,
    bottomLeftObstacle!.translated(0,100).zoomAdapted(),

  ]));

  var topRightObstacle =
      obstacleHelper.getObstaclePosition(0, topRowObstaclesCount - 1);
  var bottomRightObstacle = obstacleHelper.getObstaclePosition(
      obstacleRows - 1, bottomRowObstaclesCount - 1);

  plinko.world.add(Barrier(points: [
    topRightObstacle!.translated(0,-100).zoomAdapted(),
    topRightObstacle,
    bottomRightObstacle!,
    bottomRightObstacle.translated(0,100).zoomAdapted(),
  ]));
}
