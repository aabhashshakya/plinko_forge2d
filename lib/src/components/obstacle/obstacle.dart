import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../../../config.dart';

class Obstacle extends BodyComponent with ContactCallbacks {
  Obstacle({
    required this.row,
    required this.column,
    required this.position,
  }) : super(
    paint: Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill,
  );

  final Vector2 position;
  final int row;
  final int column;

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = obstacleRadius * 0.8;

    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..restitution = 0.0; // Bouncy effect //0.0 means no bounce

    final bodyDef = BodyDef()
    ..userData=this
      ..position =
          position // Body's center of mass position, basically Anchor.Center
      ..type = BodyType.static; //cannot move and react to contact

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    // TODO: implement beginContact
    super.beginContact(other, contact);
    final colorEffect = ColorEffect(
      const Color(0xffB59410),
      EffectController(duration: 0.4, reverseDuration: 1),
      opacityFrom: 0,
      opacityTo: 1,
    );
    final effect = GlowEffect(
        50, EffectController(duration: 0.5, reverseDuration: 0),
        style: BlurStyle.solid);
    // add(colorEffect);
    add(effect);
  }
}
