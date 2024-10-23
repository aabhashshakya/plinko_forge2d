import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:plinko_forge2d/src/components/ball.dart';
import 'package:plinko_forge2d/src/plinko_forge2d.dart';

import '../../config.dart';

class MoneyMultiplier extends BodyComponent<Plinko> with ContactCallbacks {
  MoneyMultiplier({
    required this.column,
    required this.color,
    required this.cornerRadius,
    required this.multiplierPosition,
    required this.size,
  }) : super(
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );

  final Vector2 multiplierPosition;
  final Vector2 size;
  final int column;
  final Radius cornerRadius;
  final Color color;
  late num multiplier;

  @override
  Future<void> onLoad() async {
    multiplier = moneyMultiplier[column];
    add(TextComponent(text: 'x$multiplier', textRenderer: _regular)
      ..anchor = Anchor.topCenter
      ..x = size.x / 2
      ..y = size.y * 0.3);
    return super.onLoad();
  }

  @override
  Body createBody() {
    final shape = PolygonShape();
    // The offset shifts the shape so the top-left of the box is at the body position.
    //determines that the object is drawn from topleft of the position
    //center means the position is the midpoint
    final offset =
        Vector2(size.x / 2, size.y / 2); // Half the width and height of the box
    shape.setAsBox(size.x / 2, size.y / 2, offset, 0);

    final fixtureDef = FixtureDef(shape)
      ..density = 0.0
      ..restitution = 0.0; // Bouncy effect

    final bodyDef = BodyDef()
    ..userData=this
      ..position = multiplierPosition
      ..type = BodyType.static;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (other is Ball) {
      _winCondition(other);
    }
  }

  void _winCondition(Ball ball) {
    if (ball.isRemoved || ball.isRemoving) {
      return;
    }
    ball.removeFromParent();
    game.activeBalls--;
    game.score.value = multiplier.toDouble();
    game.gameResults.value = [...game.gameResults.value, this];
    if (game.roundInfo.isSimulation) {
      //add result to CSV file
      var result = [
        ball.index.toString(), //S.N
        ball.seed.toString(), //seed
        "${multiplier}x" //result
      ];
      game.simulationResult.add(result);
    }

    if (game.activeBalls <= 0) {
      game.setPlayState(PlayState.roundOver);
    }
    final glowEffect = GlowEffect(
        20, EffectController(duration: 0.5, reverseDuration: 1),
        style: BlurStyle.solid);

    // add(colorEffect);

    // final scaleEffect = ScaleEffect.by(
    //   Vector2.all(1.1),
    //   EffectController(duration: 0.5, reverseDuration: 0.5),
    // );
    //
    // add(scaleEffect);
    add(glowEffect);

    //win condition
    //The most important new concept this code introduces is how the player achieves the win condition. The win condition
    // check queries the world for bricks, and confirms that only one remains. This might be a bit confusing, because the
    // preceding line removes this brick from its parent.
    // The key point to understand is that component removal is a queued command. It removes the brick after this code runs,
    // but before the next tick of the game world.
  }
}

final _regularTextStyle = TextStyle(
  fontSize: 18/zoom,
  color: BasicPalette.white.color,
);
final _regular = TextPaint(
  style: _regularTextStyle,
);

//total 15 money multipliers
final moneyMultiplier = [
  2.5,
  2.0,
  1.5,
  1.1,
  1.0,
  0.8,
  0.5,
  0.0, //middle
  0.5,
  0.8,
  1.0,
  1.1,
  1.5,
  2.0,
  2.5,
];

//total 15 colors
const moneyMultiplierColors = [
  // Add this const
  Color(0xfff94440),
  Color(0xfff94159),
  Color(0xfff3722c),
  Color(0xfff8961e),
  Color(0xff43aa8b),
  Color(0xff90be6d),
  Color(0xff90be9e),
  Color(0xfff9c74f),
  Color(0xff90be9e),
  Color(0xff90be6d),
  Color(0xff43aa8b),
  Color(0xfff8961e),
  Color(0xfff3722c),
  Color(0xfff94159),
  Color(0xfff94440),
];
