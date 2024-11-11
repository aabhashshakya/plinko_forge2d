import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:plinko_forge2d/config.dart';

import '../plinko_forge2d.dart';
import 'components.dart';

//Earlier, you defined the PlayArea using the RectangleComponent, so it stands to reason that more shapes exist.
// CircleComponent, like RectangleComponent, derives from PositionedComponent, so you can position the ball on the screen.
// More importantly, its position can be updated.
class Ball extends BodyComponent<Plinko> with ContactCallbacks {
  Ball({
    this.seed,
    required this.index,
    required this.ballPosition,
  }) : super(
    paint: Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill,
      );

  final Vector2 ballPosition;
  final int? seed;
  final int index;
  final Vector2 velocity =Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
      Vector2 velocityTmp = Vector2.zero();
      velocity.y += 20000 * dt;
      velocityTmp
        ..setFrom(velocity)..clamp(Vector2(-200, -10), Vector2(200, 350))
        ..scale(dt * 1.3); //scale is speed

    body.linearVelocity+=velocityTmp;


  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = ballRadius * 0.85;


    final fixtureDef = FixtureDef(shape)
      ..density = 60
      ..restitution = 0.3; // Bouncy effect

    final bodyDef = BodyDef()
      ..userData = this
      ..linearVelocity =velocity
      ..position =
          ballPosition // Body's center of mass position, basically Anchor.Center
      ..type = BodyType.dynamic; //can move and react to contact

    // Create the body in the world
    final body = world.createBody(bodyDef);

    // Create a fixture to attach the shape to the body
    body.createFixture(fixtureDef);
    // Set initial downward velocity for falling

    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    // TODO: implement beginContact
    super.beginContact(other, contact);
    if (other is Wall) {
      //game is over if ball goes out of play area
      game.activeBalls--;
      if (game.roundInfo.isSimulation) {
        //add result to CSV file
        var result = [
          index.toString(), //S.N
          "-1" //result
        ];
        game.simulationResult.add(result);
      }
      if (game.activeBalls <= 0) {
        //round over if it was the last ball
        game.setPlayState(PlayState.roundOver);
      }
      add(RemoveEffect(
        // Modify from here...
          delay: 0,
          onComplete: () {
            // Modify from here
          }));
    }
  }

}