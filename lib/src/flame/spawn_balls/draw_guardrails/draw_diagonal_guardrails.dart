///Created by Aabhash Shakya on 6/14/25
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../constants/config.dart';
import '../../components/guide_rail.dart';
import '../../plinko_forge2d.dart';

//set a color to the guard rails to see how these are drawn
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

  debugPrint(
      "PLINKO: GUIDERAIL: left diagonal: startLine: column: ${obstacleColumn}");

  while (obstacleColumnIndex > 0 && obstacleRowIndex > 0) {
    obstacleRowIndex--;
    obstacleColumnIndex--;
  }

  var actualObstacleRowIndex = max(obstacleRowIndex, 0);

  debugPrint(
      "PLINKO: GUIDERAIL: left diagonal: endLine: row: ${actualObstacleRowIndex}column: ${obstacleColumnIndex}");

  var endpointPosition = obstacleHelper.getObstaclePosition(
      actualObstacleRowIndex, obstacleColumnIndex);
  plinko.world.add(GuideRail(
      index: index,
      guideRailPosition: GuideRailPosition.left,
      points: [
        Vector2(obstaclePosition.x + 1, obstaclePosition.y + 4),
        obstaclePosition,
        endpointPosition!
      ]));
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
  debugPrint(
      "PLINKO: GUIDERAIL: right diagonal: startLine: column: ${obstacleColumn}");

  while (steps > 0) {
    obstacleRowIndex--;
    obstacleColumnIndex++;
    steps--;
  }
  var actualObstacleRowIndex = max(obstacleRowIndex, 0);
  var actualObstacleColumnIndex = min(obstacleColumnIndex,
      obstacleHelper.getMaxObstacleColumnIndexForRow(obstacleRowIndex));

  debugPrint(
      "PLINKO: GUIDERAIL: right diagonal: endLine: row: ${actualObstacleRowIndex}column: ${actualObstacleColumnIndex}");

  var endpointPosition = obstacleHelper.getObstaclePosition(
      actualObstacleRowIndex, actualObstacleColumnIndex);
  plinko.world.add(GuideRail(
      index: index,
      guideRailPosition: GuideRailPosition.right,
      points: [
        Vector2(obstaclePosition.x - 1, obstaclePosition.y + 4),
        obstaclePosition,
        endpointPosition!
      ]));
}
