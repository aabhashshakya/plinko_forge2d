import 'dart:ui';

import 'package:animated_text_lerp/animated_text_lerp.dart';
import 'package:flame/game.dart' hide Route;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plinko_forge2d/src/constants/sound_manager.dart';
import 'package:plinko_forge2d/src/dialogs/exit_game_dialog.dart';
import 'package:plinko_forge2d/src/dialogs/pause_menu.dart';
import 'package:plinko_forge2d/src/provider/game_provider.dart';
import 'package:plinko_forge2d/src/widgets/game_widgets/score_indicators/bet_indicator.dart';
import 'package:plinko_forge2d/src/widgets/game_widgets/buttons/big_button.dart';
import 'package:plinko_forge2d/src/widgets/game_widgets/buttons/big_buttonwslider.dart';
import 'package:plinko_forge2d/src/widgets/game_widgets/header.dart';
import 'package:plinko_forge2d/src/widgets/game_widgets/buttons/rounded_button.dart';
import 'package:plinko_forge2d/src/widgets/game_widgets/score_indicators/multiplier_item.dart';
import 'package:plinko_forge2d/src/widgets/game_widgets/score_indicators/winnings_indicator.dart';
import 'package:provider/provider.dart';

import '../constants/config.dart';
import '../constants/shared_prefs.dart';
import '../flame/components/money_multiplier.dart';
import '../flame/plinko_forge2d.dart';
import '../widgets/game_widgets/overlay_screen.dart';

//Most content in this file follows a standard Flutter widget tree build. The parts specific to Flame include using
// GameWidget.controlled to construct and manage the BrickBreaker game instance and the new overlayBuilderMap argument
// to the GameWidget.
//
// This overlayBuilderMap's keys must align with the overlays that the playState setter in BrickBreaker added or removed.
// Attempting to set an overlay that is not in this map leads to unhappy faces all around.

class GameApp extends StatefulWidget {
  const GameApp({super.key, required this.enableSim});

  final bool enableSim;

  static const String routeName = 'GameScreen';

  static Route getRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) {
      bool enableSim = settings.arguments as bool;
      return MultiProvider(
          providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
          child: GameApp(
            enableSim: enableSim,
          ));
    });
  }

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  final ScrollController _scrollController = ScrollController();

  late final Plinko plinko;
  late VoidCallback scoreListener;

  @override
  void initState() {
    super.initState();
    plinko = Plinko();

    //add listeners

    //called when the balls hits a money multiplier
    scoreListener = () {
      context.read<GameProvider>().updateTotalWinnings(plinko.score.value);
    };

    plinko.score.addListener(scoreListener);
  }

  @override
  void dispose() {
    super.dispose();
    plinko.score.removeListener(scoreListener);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (_) {
              return const Dialog(
                child: ExitGameDialog(),
              );
            });
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/game_bg.png"),
                  fit: BoxFit.cover)),
          child: SafeArea(
            child: Center(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(1.0)),
                child: Stack(
                  children: [
                    FittedBox(
                      child: SizedBox(
                        width: gameWidth,
                        height: gameHeight,
                        child: GameWidget(
                          game: plinko,
                          overlayBuilderMap: {
                            PlayState.roundOver.name: (context, game) {
                              SoundManager.playWinSound();
                              return Container();
                            },
                            PlayState.gameOver.name: (context, game) {
                              SoundManager.playLoseSound();
                              return OverlayScreen(
                                color: Colors.red,
                                title: 'N O   C R E D I T S',
                                subtitle:
                                    'You need ${context.read<GameProvider>().calculateMissingCredits()} more credits!',
                                onTap: () {
                                  plinko.setPlayState(PlayState.ready);
                                  plinko.overlays
                                      .remove(PlayState.gameOver.name);
                                },
                              );
                            },
                          },
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 0.h),
                            child: Header(
                                betAmount: context
                                    .watch<GameProvider>()
                                    .totalBet
                                    .toInt(),
                                totalWinnings: context
                                    .watch<GameProvider>()
                                    .roundInfo
                                    .totalWinnings
                                    .toInt(),
                                playState: plinko.getPlayState())),
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                              start: 10.w, end: 10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8.w),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return Dialog(
                                                child: PauseMenu(
                                                    onResumeTapped: () {},
                                                    onVolumeTapped:
                                                        (isSoundEnabled) {},
                                                    onExitGameTapped: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      showDialog(
                                                          context: context,
                                                          builder: (_) {
                                                            return const Dialog(
                                                              child:
                                                                  ExitGameDialog(),
                                                            );
                                                          });
                                                    }),
                                              );
                                            });
                                      },
                                      child: Container(
                                        width: 52.w,
                                        height: 42.h,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.w),
                                            border: const Border.fromBorderSide(
                                                BorderSide(
                                                    color: Colors.black)),
                                            image: const DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/options_button.png"))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  WinningsIndicator(
                                      title: "Winnings",
                                      value: context
                                          .watch<GameProvider>()
                                          .roundInfo
                                          .totalWinnings),
                                  BetIndicator(
                                      title: "Your Bet",
                                      value: context
                                          .watch<GameProvider>()
                                          .totalBet
                                          .toInt())
                                ],
                              ),
                              SizedBox(height: 10.h),
                              ValueListenableBuilder<List<MoneyMultiplier>>(
                                valueListenable: plinko.gameResults,
                                builder: (context, state, child) {
                                  if (_scrollController.hasClients) {
                                    //always scroll to the end of list automatically when new items added
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      final position = _scrollController
                                          .position
                                          .maxScrollExtent; //or minScrollExtent
                                      _scrollController.jumpTo(position);
                                    });
                                  }
                                  return SizedBox(
                                    width: 30.h,
                                    height: 200.h,
                                    child: ListView.separated(
                                      controller: _scrollController,
                                      padding: EdgeInsetsDirectional.only(
                                          start: 2.w),
                                      itemCount: state.length,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemBuilder: (_, index) {
                                        return multiplierItem(state[index]);
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return SizedBox(
                                          height: 2.h,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 2.0.h, horizontal: 8.0.w),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: BigButton(
                                  backgroundImage:
                                      "assets/images/green_button_bg.png",
                                  label: "CREDIT",
                                  iconImage: "assets/images/coin.png",
                                  value: context.watch<GameProvider>().credit,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: BigButtonSlider(
                                    buttonType: BigButtonType.balls,
                                    backgroundImage:
                                        "assets/images/pink_button_bg.png",
                                    label: "BALLS",
                                    iconImage: "assets/images/ball.png",
                                    value: context
                                        .watch<GameProvider>()
                                        .numberOfBalls,
                                    onIncrementOrDecrement: (increment) {
                                      if (plinko.getPlayState() ==
                                          PlayState.playing) {
                                        return;
                                      }
                                      plinko.setPlayState(PlayState.ready);
                                      if (increment) {
                                        context
                                            .read<GameProvider>()
                                            .increaseBalls();
                                      } else {
                                        context
                                            .read<GameProvider>()
                                            .decreaseBalls();
                                      }
                                    },
                                    min: minBalls,
                                    max: maxBalls,
                                    iconSize: 20,
                                    onSliderDragged: (count) {
                                      if (plinko.getPlayState() ==
                                          PlayState.playing) {
                                        return;
                                      }
                                      plinko.setPlayState(PlayState.ready);
                                      context
                                          .read<GameProvider>()
                                          .setBalls(count);
                                    }),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: BigButtonSlider(
                                    buttonType: BigButtonType.bet,
                                    backgroundImage:
                                        "assets/images/teal_button_bg.png",
                                    label: "BET",
                                    iconImage: "assets/images/coin.png",
                                    value: context.watch<GameProvider>().bet,
                                    min: minBet,
                                    max: maxBet,
                                    onSliderDragged: (count) {
                                      if (plinko.getPlayState() ==
                                          PlayState.playing) {
                                        return;
                                      }
                                      plinko.setPlayState(PlayState.ready);

                                      context
                                          .read<GameProvider>()
                                          .setBet(count);
                                      plinko.setPlayState(PlayState.ready);
                                    }),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                          ValueListenableBuilder<PlayState>(
                              valueListenable: plinko.playState,
                              builder: (context, state, child) {
                                return RoundedButton(
                                    enabled: state != PlayState.playing,
                                    width: 340,
                                    backgroundImage:
                                        "assets/images/yellow_button_bg.png",
                                    label: "PLAY",
                                    onTap: () {
                                      if (plinko.getPlayState() ==
                                          PlayState.playing) {
                                        return;
                                      }
                                      if (context
                                          .read<GameProvider>()
                                          .trySpendCredits()) {
                                        plinko.playGame(context
                                            .read<GameProvider>()
                                            .roundInfo);
                                      } else {
                                        plinko.setPlayState(PlayState.gameOver);
                                      }
                                    });
                              }),
                          SizedBox(height: 24.h),
                          if (widget.enableSim)
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.h)),
                              minWidth: 0,
                              padding: EdgeInsets.all(0.0.w),
                              textColor: Colors.white,
                              elevation: 16.0.h,
                              child: Container(
                                margin: EdgeInsets.zero,
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.h),
                                  image: const DecorationImage(
                                      image:
                                          AssetImage('assets/images/bg.jpeg'),
                                      fit: BoxFit.cover),
                                ),
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.0.w, vertical: 8.0.h),
                                    child: ValueListenableBuilder<PlayState>(
                                      valueListenable: plinko.playState,
                                      builder: (context, state, child) {
                                        return Text(
                                          "SIM",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                              color: Colors.white),
                                        );
                                      },
                                    )),
                              ),
                              // ),
                              onPressed: () {
                                if (plinko.getPlayState() ==
                                    PlayState.playing) {
                                  return;
                                }
                                if (context
                                    .read<GameProvider>()
                                    .trySpendCredits()) {
                                  plinko.simulateGame(
                                      context.read<GameProvider>().roundInfo);
                                } else {
                                  plinko.setPlayState(PlayState.gameOver);
                                }
                              },
                            ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _roundedTextField(String title, int value) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.white)),
      Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.h),
          image: const DecorationImage(
              image: AssetImage('assets/images/bg.jpeg'), fit: BoxFit.cover),
        ),
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 8.0.h),
            child: AnimatedNumberText(
              value, // int or double
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 500),
              style: const TextStyle(color: Colors.white),
              formatter: (value) {
                return "\$$value";
              },
            )),
      ),
    ],
  );
}

Widget ballsSlider(int value, Function(int) onChanged) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Balls : $value",
          style: TextStyle(fontSize: 12.sp, color: Colors.white)),
      Container(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.h),
            image: const DecorationImage(
                image: AssetImage('assets/images/bg.jpeg'), fit: BoxFit.cover),
          ),
          child: Slider(
              value: value.toDouble(),
              activeColor: Colors.orange,
              inactiveColor: Colors.orange.withOpacity(0.5),
              min: minBalls.toDouble(),
              max: maxBalls.toDouble(),
              onChanged: (count) {
                onChanged(count.toInt());
              })),
    ],
  );
}

Widget _roundedTextFieldWithButtons(
    String title, String value, Function onIncrement, Function onDecrement) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.white)),
      Container(
        constraints:
            BoxConstraints(minWidth: 50.w, maxWidth: 230.w, maxHeight: 40.h),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.h),
          image: const DecorationImage(
              image: AssetImage('assets/images/bg.jpeg'), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 8.0.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(value,
                      style: TextStyle(fontSize: 12.sp, color: Colors.white))),
              ElevatedButton(
                onPressed: () {
                  onDecrement();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 0),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  backgroundColor: Colors.pink,
                  // <-- Button color
                  foregroundColor: Colors.red, // <-- Splash color
                ),
                child: const Icon(Icons.remove, color: Colors.white),
              ),
              ElevatedButton(
                onPressed: () {
                  onIncrement();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 0),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  backgroundColor: Colors.pink,
                  // <-- Button color
                  foregroundColor: Colors.red, // <-- Splash color
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
