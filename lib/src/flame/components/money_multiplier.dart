import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plinko_forge2d/src/constants/sound_manager.dart';
import 'package:plinko_forge2d/src/flame/plinko_forge2d.dart';
import 'package:plinko_forge2d/src/utils/extensions.dart';

import '../../constants/shared_prefs.dart';
import 'ball.dart';
import '../../constants/config.dart';
import 'collision_configs.dart';
import 'guide_rail.dart';

class MoneyMultiplier extends BodyComponent<Plinko> with ContactCallbacks {
  MoneyMultiplier({
    required this.column,
    required this.cornerRadius,
    required this.multiplierPosition,
    required this.size,
  }) : super(
          paint: Paint()
            ..color = Colors.transparent
            ..style = PaintingStyle.fill,
        );

  final Vector2 multiplierPosition;
  final Vector2 size;
  final int column;
  final Radius cornerRadius;
  late num multiplier;
  late SpriteComponent visualComponent;

  @override
  Future<void> onLoad() async {
    multiplier = moneyMultiplier[column];
    var sprite = await Sprite.load(moneyMultiplierAsset[column]);
    visualComponent =
        SpriteComponent(sprite: sprite, size: size, anchor: Anchor.topLeft);

    visualComponent
        .add(TextComponent(text: 'x$multiplier', textRenderer: _regular)
          ..anchor = Anchor.topCenter
          ..x = size.x / 2.02
          ..y = size.y * 0.28);
    add(visualComponent);

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

    var filter = Filter()
      ..categoryBits = CategoryBits.moneyMultipliers
      //maskBits means collision will be only detected with these components
      ..maskBits = CategoryBits.ball;

    final fixtureDef = FixtureDef(shape)
      ..filter = filter
      ..density = 0.0
      ..restitution = 0.0; // Bouncy effect

    final bodyDef = BodyDef()
      ..userData = this
      ..position = multiplierPosition
      ..type = BodyType.static;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    super.beginContact(other, contact);
    if (other is Ball) {
      SoundManager.playMoneyMultiplierSound();
      applyEffect();

      _winCondition(other);
    }
  }

  void _winCondition(Ball ball) {
    if (ball.isRemoved || ball.isRemoving) {
      return;
    }

    //remove the ball n and guide
    Future.microtask(() {
      //remove the guiderails for the ball
      final guideRailsToRemove = game.world.children
          .whereType<GuideRail>()
          .where((guide) => guide.index == ball.index)
          .toList();
      for (final guide in guideRailsToRemove) {
        world.destroyBody(guide.body);
        guide.removeFromParent();
      }
      world.destroyBody(ball.body);
      ball.removeFromParent();

      game.activeBalls--;
      game.score.value = multiplier.toDouble();
      game.gameResults.value = [...game.gameResults.value, this];

      //write data if simulation
      if (game.roundInfo.isSimulation) {
        //add result to CSV file
        var result = [
          ball.index.toString(), //S.N
          "${multiplier}x",
          column.toString()
          //result
        ];
        game.simulationResult.add(result);
      }

      if (game.activeBalls <= 0) {
        game.setPlayState(PlayState.roundOver);
      }
    });


    //win condition
    //The most important new concept this code introduces is how the player achieves the win condition. The win condition
    // check queries the world for bricks, and confirms that only one remains. This might be a bit confusing, because the
    // preceding line removes this brick from its parent.
    // The key point to understand is that component removal is a queued command. It removes the brick after this code runs,
    // but before the next tick of the game world.
  }

  void applyEffect() {
    visualComponent.add(MoveByEffect(
      Vector2(0, 15).zoomAdapted(),
      EffectController(duration: 0.3, reverseDuration: 0.2),
    ));
  }
}

final _regularTextStyle = GoogleFonts.poppins(
    fontSize: 18 / zoom,
    color: BasicPalette.white.color,
    fontWeight: FontWeight.bold,
    //shadows to give it the text an outline
    shadows: [
      Shadow(color: Colors.black, blurRadius: 3.w),
      Shadow(color: Colors.black, blurRadius: 3.w),
      Shadow(color: Colors.black, blurRadius: 3.w),
      Shadow(color: Colors.black, blurRadius: 3.w)
    ]);

final _regular = TextPaint(style: _regularTextStyle);

//total 15 money multipliers
final moneyMultiplier = [
  56,
  23,
  10,
  5,
  2,
  1,
  0.7,
  0, //middle
  0.7,
  1,
  2,
  5,
  10,
  23,
  56,
];

//total 15 colors
const moneyMultiplierAsset = [
  // Add this const
  "bucket7.png",
  "bucket6.png",
  "bucket5.png",
  "bucket4.png",
  "bucket3.png",
  "bucket2.png",
  "bucket1.png",
  "bucket0.png",
  "bucket1.png",
  "bucket2.png",
  "bucket3.png",
  "bucket4.png",
  "bucket5.png",
  "bucket6.png",
  "bucket7.png",
];
