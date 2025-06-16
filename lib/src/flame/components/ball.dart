import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:plinko_forge2d/src/constants/config.dart';
import 'package:plinko_forge2d/src/flame/components/collision_configs.dart';
import 'package:plinko_forge2d/src/flame/components/guide_rail.dart';
import 'package:plinko_forge2d/src/utils/extensions.dart';

import '../plinko_forge2d.dart';
import 'components.dart';

//Earlier, you defined the PlayArea using the RectangleComponent, so it stands to reason that more shapes exist.
// CircleComponent, like RectangleComponent, derives from PositionedComponent, so you can position the ball on the screen.
// More importantly, its position can be updated.
class Ball extends BodyComponent<Plinko> with ContactCallbacks {
  Ball(
      {this.seed,
      this.velocity,
      required this.index,
      required this.ballPosition,
      required this.predeterminedBucketIndex,
      required this.predeterminedBucketPosition})
      : super(
          paint: Paint()
            ..color = Colors.transparent
            ..style = PaintingStyle.fill,
        );

  final Vector2 ballPosition;
  final int? seed;
  final int index;
  bool isFirstCollision = true;
  Vector2? velocity;
  int predeterminedBucketIndex;
  Vector2 predeterminedBucketPosition;

  final restitution = 0.55;

  double stuckThreshold = 15; // velocity magnitude below this = "stuck"
  int stuckFrameCount = 0;
  int stuckFrameLimit = 60; // number of frames before you consider it stuck

  @override
  Future<void> onLoad() async {
    super.onLoad();
    velocity ??= Vector2(0, 40);
    var sprite = await Sprite.load("ball.png");
    var size = Vector2(50, 50).zoomAdapted();
    var s = SpriteComponent(sprite: sprite, size: size, anchor: Anchor.center);
    add(s);
  }

  @override
  void update(double dt) {
    super.update(dt);
    Vector2 velocityTmp = Vector2.zero();
    velocity!.y += Random().randomBetween(15, 25) * dt;

    velocityTmp
      ..setFrom(velocity!)
      ..clamp(Vector2(-90, -150), Vector2(90, 100))
      ..scale(dt * 1.3); //scale is speed
    body.linearVelocity += velocityTmp;

    debugPrint('Plinko: Linear velocity length: ${body.linearVelocity.length}');
    if (body.linearVelocity.length < stuckThreshold) {
      stuckFrameCount++;
    } else {
      stuckFrameCount = 0; // reset if ball moves
    }

    if (stuckFrameCount > stuckFrameLimit) {
      debugPrint('Plinko: Ball is stuck!');
      double dx = predeterminedBucketPosition.x - body.position.x;
      final impulse =
          Vector2(dx.sign * 50, -50); // little force in the direction of bucket
      body.applyLinearImpulse(impulse);
    }
  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = ballRadius * 0.3;

    var filter = Filter()
      ..categoryBits = CategoryBits.ball
      //maskBits means collision will be only detected with these components
      //here the purpose to do negate the collision between balls
      ..maskBits = CategoryBits.obstacles |
          CategoryBits.moneyMultipliers |
          //  CategoryBits.ball |
          CategoryBits.wall |
          CategoryBits.guideRails;

    final fixtureDef = FixtureDef(shape)
      ..filter = filter
      ..density = 7.5
      ..restitution = restitution;
    /**
        ..restitution = 0.1; // Bouncy effect
     **/

    final bodyDef = BodyDef()
      ..userData = this
      ..linearVelocity = velocity!
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
  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    if (other is GuideRail) {
      final GuideRail guideRail = other;
      if (guideRail.index != index) {
        contact.isEnabled = false;
      }
    }
    if (other is Ball) {
      contact.isEnabled = false;
    }
    if (other is Obstacle) {
      if (other.row == 0) {
        body.fixtures[0].restitution = 0.0;
      } else {
        body.fixtures[0].restitution = restitution;
      }
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (other is Wall) {
      //game is over if ball goes out of play area
      Future.microtask(() {
        //remove the guiderails for the ball
        final guideRailsToRemove = game.world.children
            .whereType<GuideRail>()
            .where((guide) => guide.index == index)
            .toList();
        for (final guide in guideRailsToRemove) {
          world.destroyBody(guide.body);
          guide.removeFromParent();
        }
        world.destroyBody(body);
        removeFromParent();
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
      });
    }

    if (other is Obstacle) {
      // 🔽logic to slightly steer the ball toward the predetermined bucket
      double dx = predeterminedBucketPosition.x - body.position.x;
      if (dx.abs() > 25) {
        // if ball's x position is too far from bucket's x position, apply some force in that direction
        final impulse = Vector2(dx.sign * 35, -20); // Adjust as needed
        body.applyLinearImpulse(impulse);
      } else {
        //apply little force in that direction anyways, just to prevent any stalls
        final impulse = Vector2(dx.sign * 10, -20);
        body.applyLinearImpulse(impulse);
      }
    }

    if (other is GuideRail) {
      if (predeterminedBucketPosition.y - position.y >
          (moneyMultiplierSize.y / 2)) {
        //make the collision with guiderails, extra strong on the extra direction
        //if the ball is already close to the bucket, don't do this
        if (other.guideRailPosition == GuideRailPosition.left) {
          body.applyLinearImpulse(Vector2(20, -10));
        } else {
          body.applyLinearImpulse(Vector2(-20, -10));
        }
      }
    }
  }
}
