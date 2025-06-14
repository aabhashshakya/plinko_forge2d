import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:plinko_forge2d/src/constants/config.dart';
import 'package:plinko_forge2d/src/flame/plinko_forge2d.dart';

import 'collision_configs.dart';

//barrier in triangle shape to prevent ball going out
class Barrier extends BodyComponent with ContactCallbacks {
  final Vector2 start;
  final Vector2 end;

  Barrier({required this.start, required this.end})
      : super(
            paint: Paint()
              ..color = Colors.blue
              ..style = PaintingStyle.fill);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);

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
  var obstacleHelper = plinko.obstacleHelper;
  var topLeftObstacle = obstacleHelper.getObstaclePosition(0, 0);
  var bottomLeftObstacle =
      obstacleHelper.getObstaclePosition(obstacleRows - 1, 0);
  plinko.world.add(Barrier(start: topLeftObstacle, end: bottomLeftObstacle));

  var topRightObstacle =
      obstacleHelper.getObstaclePosition(0, topRowObstaclesCount-1);
  var bottomRightObstacle = obstacleHelper.getObstaclePosition(
      obstacleRows - 1, bottomRowObstaclesCount - 1);
  plinko.world.add(Barrier(start: topRightObstacle, end: bottomRightObstacle));
}
