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

void spawnBalls(Plinko plinko) {
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
      predeterminedMultiplier: moneyMultiplier.shuffled().first);
  plinko.ballsSpawned++;

  // Schedule the next spawn
  /** Future.delayed(const Duration(milliseconds: 350), _spawnBalls); **/
  Future.delayed(const Duration(milliseconds: 350), () {
    spawnBalls(plinko);
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
  drawLeftDiagonalLine(plinko,
      index: index,
      obstaclePosition: leftObstaclePosition,
      obstacleColumn: bucketIndex);
  drawRightDiagonalLine(plinko,
      index: index,
      obstaclePosition: rightObstaclePosition,
      obstacleColumn: bucketIndex + 1);
}

void drawLeftDiagonalLine(Plinko plinko,
    {required int index,
    required Vector2 obstaclePosition,
    required int obstacleColumn}) {
  if (obstacleColumn == 0) {
    return;
  }
  var obstacleHelper = plinko.obstacleHelper;
// the obstacle position is the botom obstacle which is starting point to draw line
// we need to find the endpoint of the line, that is diagonal and drwas thwought the obstcales
  var obstacleRowIndex = obstacleRows - 1;
  var obstacleColumnIndex = obstacleColumn;


  debugPrint("PLINKO: GUIDERAIL: left diagonal: startLine: column: ${obstacleColumn}");


  while (obstacleColumnIndex > 0 && obstacleRowIndex>0) {
    obstacleRowIndex--;
    obstacleColumnIndex--;
  }

  var actualObstacleRowIndex = max(obstacleRowIndex,
      0);


  debugPrint(
      "PLINKO: GUIDERAIL: left diagonal: endLine: row: ${actualObstacleRowIndex}column: ${obstacleColumnIndex}");

  var endpointPosition =
      obstacleHelper.getObstaclePosition(actualObstacleRowIndex, obstacleColumnIndex);
  plinko.world.add(
      GuideRail(index: index, points: [obstaclePosition,  endpointPosition]));
}

void drawRightDiagonalLine(Plinko plinko,
    {required int index,
    required Vector2 obstaclePosition,
    required int obstacleColumn}) {
  if (obstacleColumn == bottomRowObstaclesCount - 1) {
    return;
  }
  var steps = bottomRowObstaclesCount - 1 - obstacleColumn;
  var obstacleHelper = plinko.obstacleHelper;
// the obstacle position is the botom obstacle which is starting point to draw line
// we need to find the endpoint of the line, that is diagonal and drwas thwought the obstcales
  var obstacleRowIndex = obstacleRows - 1;
  var obstacleColumnIndex = obstacleColumn;
  debugPrint("PLINKO: GUIDERAIL: right diagonal: startLine: column: ${obstacleColumn}");

  while (steps > 0) {
    obstacleRowIndex--;
    obstacleColumnIndex++;
    steps--;
  }
  var actualObstacleRowIndex = max(obstacleRowIndex,
      0);
  var actualObstacleColumnIndex = min(obstacleColumnIndex,
      obstacleHelper.getMaxObstacleColumnIndexForRow(obstacleRowIndex));

  debugPrint(
      "PLINKO: GUIDERAIL: right diagonal: endLine: row: ${actualObstacleRowIndex}column: ${actualObstacleColumnIndex}");

  var endpointPosition = obstacleHelper.getObstaclePosition(
      actualObstacleRowIndex, actualObstacleColumnIndex);
  plinko.world.add(
      GuideRail(index: index, points:[obstaclePosition, endpointPosition]));
}
