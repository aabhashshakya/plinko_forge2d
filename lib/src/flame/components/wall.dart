import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:plinko_forge2d/src/flame/components/collision_configs.dart';
import 'package:plinko_forge2d/src/utils/extensions.dart';

import '../plinko_forge2d.dart';
import 'ball.dart';

class Wall extends BodyComponent<Plinko> with ContactCallbacks {
  @override
  final Vector2 position;
  final Vector2 size;

  Wall(this.position, this.size) :super(  paint: Paint()
    ..color = Colors.transparent
    ..style = PaintingStyle.fill);

  @override
  Body createBody() {
    // Define the body of the wall
    final shape = PolygonShape();
    shape.setAsBoxXY(size.x / 2, size.y / 2);  // Set the dimensions of the wall

    // Define the body definition (static)
    final bodyDef = BodyDef()
    ..userData =this
      ..position = position
      ..type = BodyType.static;  // Static body, it doesn't move

    var filter = Filter()
      ..categoryBits = CategoryBits.wall
    //maskBits means collision will be only detected with these components
      ..maskBits = CategoryBits.ball;

    final fixtureDef = FixtureDef(shape)
      ..filter = filter;
       //

    // Create the body in the world
    final body = world.createBody(bodyDef);

    // Create a fixture to attach the shape to the body
    body.createFixture(fixtureDef);

    return body;
  }
}

void createWalls(Forge2DGame game) {
  // Example screen size (replace with actual screen size)
  final screenSize = Vector2(game.size.x, game.size.y);

  // Create and add four walls (boundaries)
  game.world.add(Wall(Vector2(screenSize.x / 2, screenSize.y - 5)..zoomAdapted(), Vector2(screenSize.x, 5)..zoomAdapted()));  // Bottom wall
  game.world.add(Wall(Vector2(screenSize.x / 2, 5)..zoomAdapted(), Vector2(screenSize.x, 5)..zoomAdapted()));  // Top wall
  game.world.add(Wall(Vector2(5, screenSize.y / 2)..zoomAdapted(), Vector2(5, screenSize.y).zoomAdapted()));  // Left wall
  game.world.add(Wall(Vector2(screenSize.x - 5, screenSize.y / 2)..zoomAdapted(), Vector2(5, screenSize.y).zoomAdapted()));  // Right wall
}
