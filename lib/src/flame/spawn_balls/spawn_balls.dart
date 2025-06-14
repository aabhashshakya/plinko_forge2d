///Created by Aabhash Shakya on 6/14/25
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:plinko_forge2d/src/flame/components/components.dart';
import 'package:plinko_forge2d/src/flame/components/guide_rail.dart';
import 'package:plinko_forge2d/src/utils/extensions.dart';

import '../../constants/config.dart';
import '../components/ball.dart';
import '../plinko_forge2d.dart';
import 'draw_guardrails/draw_diagonal_guardrails.dart';
import 'draw_guardrails/draw_polyline_guardrails.dart';

void spawnBalls(Plinko plinko, {required num predeterminedMultiplier}) {
  if (!plinko.isSpawning || plinko.ballsSpawned >= plinko.roundInfo.balls)
    return;
  var world = plinko.world;

  //This change adds the Ball component to the world. To set the ball's position to the center of the display area,
  // the code first halves the size of the game, as Vector2 has operator overloads (* and /) to scale a Vector2 by a
  // scalar value.
  // To set the ball's velocity involves more complexity. The intent is to move the ball down the screen in a random
  // direction at a reasonable speed. The call to the normalized method creates a Vector2 object set to the same
  // direction as the original Vector2, but scaled down to a distance of 1. This keeps the speed of the ball consistent
  // no matter which direction the ball goes. The ball's velocity is then scaled up to be a 1/4 of the height of the game.
  // Getting these various values right involves some iteration, also known as playtesting in the industry.
  var random = Random().nextDouble();

  /** var offset = Random().randomBetween(-35, 35); **/
  var offset = random > 0.5 ? 40 : -40;

  world.add(Ball(
    /** velocity: Vector2(Random().randomBetween(-3, 3).toDouble(),
        Random().randomBetween(0, 30).toDouble()), **/
    index: plinko.ballsSpawned,
    ballPosition: Vector2(plinko.width / 2 + offset, plinko.height / 4)
      ..zoomAdapted(),
    //initial position of the ball, which s  center
  )); //scale is the speed, how fast it moves
  _buildGuideRails(plinko,
      index: plinko.ballsSpawned,
      predeterminedMultiplier: predeterminedMultiplier);
  plinko.ballsSpawned++;

  // Schedule the next spawn
  /** Future.delayed(const Duration(milliseconds: 350), _spawnBalls); **/
  Future.delayed(const Duration(milliseconds: 350), () {
    spawnBalls(plinko, predeterminedMultiplier: predeterminedMultiplier);
  });
}

void _buildGuideRails(Plinko plinko,
    {required int index, required num predeterminedMultiplier}) {
  var obstacleHelper = plinko.obstacleHelper;
  //get the indexes of the bucket that match the money multiplier
  final bucketIndexes = moneyMultiplier
      .asMap()
      .entries
      .where((entry) => entry.value == predeterminedMultiplier)
      .map((entry) => entry.key)
      .toList();
  final bucketIndex = bucketIndexes.shuffled().first;

  //get the two obstacles directly above the bucket
  //eg:
  // 0   0   0   0   X     X  0   0   0   0
  // .    .   .   .  | 0x |   .   .   .   .
  int finalObstacleRowIndex = obstacleRows - 1;
  var leftObstaclePosition =
      obstacleHelper.getObstaclePosition(finalObstacleRowIndex, bucketIndex);
  var rightObstaclePosition = obstacleHelper.getObstaclePosition(
      finalObstacleRowIndex, bucketIndex + 1);

  if (bucketIndex < ((obstacleRows / 2).toInt() - 2)) {
    //predetermined bucked is in far left side, where right diagonals as guiderails just wont cut it
    drawLeftDiagonalLine(plinko,
        index: index,
        obstaclePosition: leftObstaclePosition!,
        obstacleColumn: bucketIndex);
    drawRightPolyLine(plinko,
        index: index,
        obstaclePosition: rightObstaclePosition!,
        obstacleColumn: bucketIndex + 1);
  } else if (bucketIndex > ((obstacleRows / 2).toInt() + 2)) {
    //predetermined bucked is in far right side, where left diagonals as guiderails just wont cut it
    drawLeftPolyLine(plinko,
        index: index,
        obstaclePosition: leftObstaclePosition!,
        obstacleColumn: bucketIndex);
    drawRightDiagonalLine(plinko,
        index: index,
        obstaclePosition: rightObstaclePosition!,
        obstacleColumn: bucketIndex + 1);
  } else {
    //predetermined bucked in more or less in the center of the screen
    drawLeftDiagonalLine(plinko,
        index: index,
        obstaclePosition: leftObstaclePosition!,
        obstacleColumn: bucketIndex);
    drawRightDiagonalLine(plinko,
        index: index,
        obstaclePosition: rightObstaclePosition!,
        obstacleColumn: bucketIndex + 1);
  }
}
