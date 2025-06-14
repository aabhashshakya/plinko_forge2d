///Created by Aabhash Shakya on 9/11/24
import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:plinko_forge2d/src/flame/components/barrier.dart';
import 'package:plinko_forge2d/src/flame/components/guide_rail.dart';
import 'package:plinko_forge2d/src/flame/spawn_balls/spawn_balls.dart';
import 'package:plinko_forge2d/src/model/round_info.dart';
import 'package:plinko_forge2d/src/utils/always_notify_value_notifier.dart';
import 'package:plinko_forge2d/src/utils/extensions.dart';
import 'package:to_csv/to_csv.dart';

import '../constants/config.dart';
import 'components/components.dart';
import 'components/money_multiplier.dart';
import 'components/obstacle/obstacle.dart';
import 'components/obstacle/obstacle_helper.dart';

enum PlayState { ready, playing, roundOver, gameOver } // Add this enumeration

class Plinko extends Forge2DGame {
  //Forge2DGame has a built-in CameraComponent and has a zoom level set to 10 by default, so your components will
  // be a lot bigger than in a normal Flame game. This is due to the SPEED LIMIT in the Forge2D world,
  // which you would hit very quickly if you are using it with zoom = 1.0. You can easily change the zoom
  // level either by calling super(zoom: yourZoom) in your constructor or
  // doing game.cameraComponent.viewfinder.zoom = yourZoom; at a later stage.
  //SO WE NEED TO ADAPT ALL COMPONENTS SIZE, POSITION, ETC BY THIS FACTOR, I.E IF ZOOM = 10, SIZE = SIZE /10
  Plinko()
      : super(
          zoom: zoom,
          gravity: Vector2(0, 10),
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );



  //Lock game to 60fps
  static const double fixedTimeStep = 1 / 60;
  double accumulator = 0;

  @override
  void update(double dt) {
    // Accumulate the elapsed time
    accumulator += dt;

    // Execute fixed update steps as long as the accumulator allows
    while (accumulator >= fixedTimeStep) {
      super.update(fixedTimeStep); // Forge2D's internal update method
      accumulator -= fixedTimeStep;
    }

    // Note: Any leftover time in the accumulator will be carried to the next frame,
    // ensuring stable physics updates over time.
  }


  //ball spawn logic //to pause spawning when engine is paused
  var predeterminedMultiplier = 0;
  bool isSpawning = false;
  int ballsSpawned = 0; // Tracks the number of balls spawned
  void _startSpawningBalls() {
    ballsSpawned = 0; // Reset the counter when starting
    isSpawning = true;
    spawnBalls(this,predeterminedMultiplier: predeterminedMultiplier);
  }


  var roundInfo = RoundInfo.getDefault();
  var activeBalls = minBalls;

  late ObstacleHelper obstacleHelper;

  //obstacle position
  late Vector2 topLeftObstaclePosition;
  late Vector2 topRightObstaclePosition;
  late Vector2 endLeftObstaclePosition;
  late Vector2 endRightObstaclePosition;

  //last row obstacles count
  final int _lastRowObstaclesCount = obstacleRows +
      topRowObstaclesCount -
      1; // -1 as index starts from 0 and o < _maxRows

  final rand = math.Random();

  final AlwaysNotifyValueNotifier<double> score = AlwaysNotifyValueNotifier(0);
  final ValueNotifier<List<MoneyMultiplier>> gameResults = ValueNotifier([]);

  double get width => size.x;

  double get height => size.y;

  final ValueNotifier<PlayState> playState =
      ValueNotifier(PlayState.ready); // Add from here...

  PlayState getPlayState() {
    return playState.value;
  }

  List<List<String>> simulationResult =
      []; //for simulation, store results of simulation
  void setPlayState(PlayState state) {
    playState.value = state;
    switch (playState.value) {
      case PlayState.roundOver:
        {
          overlays.removeAll(PlayState.values.map((e) => e.name));
          overlays.add(playState.value.name);

          if (roundInfo.isSimulation) {
            //write simulation output in a CSV
            // List<String> header = ["Ball ID", "result", "prize_column"];
            // myCSV(header, simulationResult, fileName: "plinko_results")
            //     .then((_) {
            //write probability output in csv
            var moneyMultipliers = moneyMultiplier
                .mapIndexed((index, e) => "${e}x,$index")
                .toList();
            Map<String, int> occurenceMap = {
              for (var e in moneyMultipliers) e: 0
            };

            for (var e in simulationResult) {
              var multiplier = "${e[1]},${e.last}";
              if (!occurenceMap.containsKey(multiplier)) {
                occurenceMap[multiplier] = 1;
              } else {
                occurenceMap[multiplier] = occurenceMap[multiplier]! + 1;
              }
            }
            List<String> header2 = occurenceMap.keys
                .toList(); // the multipliers are the column headers
            List<String> column1 = occurenceMap.values
                .map((e) => e.toString())
                .toList(); //no. of times ball hit those multipliers
            List<String> column2 = column1
                .map((e) => "${(int.parse(e) / roundInfo.balls) * 100}%")
                .toList(); //the probability of being hit

            //add a total
            header2.add("Total balls");
            column1.add("${roundInfo.balls}");
            column2.add((""));

            //add RTP header
            header2.add("RTP");
            column1.add("${roundInfo.totalWinnings}/${roundInfo.totalBet}=");
            column2.add(
                ("${(roundInfo.totalWinnings.toDouble() / roundInfo.totalBet) * 100}%"));

            myCSV(header2, [column1, column2], fileName: "plinko_distribution");
            //   });
          }
        }
      case PlayState.playing || PlayState.ready:
        {
          overlays.removeAll(PlayState.values.map((e) => e.name));
        }
      case PlayState.gameOver:
        {
          overlays.removeAll(PlayState.values.map((e) => e.name));
          overlays.add(playState.value.name);
        }
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    obstacleHelper = ObstacleHelper();
    //By default, Flame follows Flutter’s canvas anchoring, which means that (0, 0) is anchored on the top left corner
    // of the canvas. So the game and all components use that same anchor by default. We can change this by changing
    // our component’s anchor attribute to Anchor.center, which will make our life way easier if you want to center the
    // component on the screen.
    camera.viewfinder.anchor = Anchor.topLeft;
    setPlayState(PlayState.ready);

    //Adds the PlayArea to the world. The world represents the game world. It projects all of its children through the
    // CameraComponents view transformation.

    loadGame();
  }

  void loadGame() {
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Barrier>());
    world.removeAll(world.children.query<GuideRail>());
    world.removeAll(world.children.query<Obstacle>());
    world.removeAll(world.children.query<MoneyMultiplier>());
    world.removeAll(world.children.query<Wall>());

    createWalls(this);
    createBarrier(this);

    world.addAll([
      // Add from here...
      for (var i = 0; i < obstacleRows; i++)
        for (var j = 0;
            j < (topRowObstaclesCount + i);
            j++) //start with 3 obstacles in the 1st row
          Obstacle(
            row: i,
            column: j,
            position: obstacleHelper.getObstaclePosition(i, j)!..zoomAdapted(),
          )
    ]);

    //money multipler at the bottom that catches the ball
    world.addAll([
      //eg: if 12 obstacles in last row, we need 11 money multipliers to fill all the gaps
      for (var i = 0; i < _lastRowObstaclesCount - 1; i++)
        MoneyMultiplier(
            column: i,
            cornerRadius: const Radius.circular(12),
            multiplierPosition: _calculateMoneyMultiplierPosition(i),
            size: _calculateMoneyMultiplierSize())
    ]);
  }

  Future<void> playGame(RoundInfo info) async {
    if (playState.value == PlayState.playing) return;
    roundInfo = info;
    activeBalls = roundInfo.balls;
    world.removeAll(world.children.query<Ball>());
    score.value = 0;
    gameResults.value = [];
    setPlayState(PlayState.playing);
    _startSpawningBalls();

  }

  Future<void> simulateGame(RoundInfo info) async {
    if (playState.value == PlayState.playing) return;
    simulationResult = []; //reset simulation results
    roundInfo = info..isSimulation = true;
    activeBalls = roundInfo.balls;
    world.removeAll(world.children.query<Ball>());
    score.value = 0;
    gameResults.value = [];
    setPlayState(PlayState.playing);
    _startSpawningBalls();
  }

  @override
  Color backgroundColor() => Colors.transparent; //make game transparent

  Vector2 _calculateMoneyMultiplierPosition(int column) {
    var bottomPadding = 30 / zoom;
    var bottomObstacle = obstacleHelper.getObstaclePosition(
        obstacleRows - 1, column); //-1 as index is 0 < maxRows

    return Vector2(bottomObstacle!.x, bottomObstacle.y + bottomPadding);
  }

  Vector2 _calculateMoneyMultiplierSize() {
    var height = 95.0;
    var width = obstacleDistance.toDouble() + 5;
    return Vector2(width, height)..zoomAdapted();
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    switch (state) {
      case AppLifecycleState.resumed:
        {
          resumeEngine();
          if (playState.value == PlayState.playing && ballsSpawned < roundInfo.balls) {
            isSpawning = true;
            spawnBalls(this,predeterminedMultiplier: predeterminedMultiplier); // Resume spawning if the limit isn't reached
          }
        }

      case AppLifecycleState.paused:
        {
          isSpawning = false; // Stop spawning
          pauseEngine();
        }
      default:
        {
          //other cases are already handled in super
        }
    }
  }
}
