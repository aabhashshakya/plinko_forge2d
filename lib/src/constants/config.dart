import 'package:flame/components.dart';
import 'package:plinko_forge2d/src/utils/extensions.dart';

///Created by Aabhash Shakya on 9/11/24

//This game will be 820 pixels wide and 1600 pixels high. The game area scales to fit the window in which it is displayed,
//but all the components added to the screen conform to this height and width.
const zoom = 10.0;
const gameWidth = 900.0;
const gameHeight = 1400.0;
const ballRadius = (gameWidth * 0.020) / zoom;

//obstacles
const obstacleRows = 14;
const obstacleDistance = 55;
const topRowObstaclesCount = 3;
const bottomRowObstaclesCount = obstacleRows + topRowObstaclesCount - 1;
const obstacleRadius = (ballRadius * 0.525) *0.8;
const obstacleGutter = gameWidth * 0.022;

//game config
const minBet = 10;
const maxBet = 10000;
const minBalls = 1;
const maxBalls = 50;
const defaultCredit = 99999;

//money multiplier

var moneyMultiplierSize = Vector2(obstacleDistance.toDouble() + 5, 95.0)
  ..zoomAdapted();
