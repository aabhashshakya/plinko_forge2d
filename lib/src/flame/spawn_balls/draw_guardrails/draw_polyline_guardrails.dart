///Created by Aabhash Shakya on 6/14/25
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../constants/config.dart';
import '../../components/guide_rail.dart';
import '../../plinko_forge2d.dart';

void drawLeftPolyLine(Plinko plinko,
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

  var points = <Vector2>[
    Vector2(obstaclePosition.x + 1, obstaclePosition.y + 4),
    obstaclePosition
  ];
  while (obstacleColumnIndex > 0 && obstacleRowIndex > 0) {
    obstacleColumnIndex = obstacleColumnIndex - 2;
    obstacleRowIndex--;
    var newPoint = obstacleHelper.getObstaclePosition(
        obstacleRowIndex, max(0, obstacleColumnIndex));
    if (newPoint != null) {
      points.add(newPoint);
    }
    obstacleRowIndex--;
    obstacleColumnIndex--;
    var newerPoint = obstacleHelper.getObstaclePosition(
        obstacleRowIndex, max(0, obstacleColumnIndex));
    if (newerPoint != null) {
      points.add(newerPoint);
    }
  }
  plinko.world.add(GuideRail(index: index, points: points));
}

void drawRightPolyLine(Plinko plinko,
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
  var points = <Vector2>[
    Vector2(obstaclePosition.x - 1, obstaclePosition.y + 4),
    obstaclePosition
  ];
  while (obstacleColumnIndex > 0 && obstacleRowIndex > 0) {
    obstacleColumnIndex = obstacleColumnIndex + 1;
    obstacleRowIndex--;
    var newPoint = obstacleHelper.getObstaclePosition(
        obstacleRowIndex,
        min(obstacleHelper.getMaxObstacleColumnIndexForRow(obstacleRowIndex),
            obstacleColumnIndex));
    if (newPoint != null) {
      points.add(newPoint);
    }
    obstacleRowIndex--;
    obstacleColumnIndex++;
    var newerPoint = obstacleHelper.getObstaclePosition(
        obstacleRowIndex,
        min(obstacleHelper.getMaxObstacleColumnIndexForRow(obstacleRowIndex),
            obstacleColumnIndex));
    if (newerPoint != null) {
      points.add(newerPoint);
    }
  }
  plinko.world.add(GuideRail(index: index, points: points));
}
