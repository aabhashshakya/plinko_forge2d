import 'dart:ui';

import 'package:animated_text_lerp/animated_text_lerp.dart';
import 'package:flame/game.dart' hide Route;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plinko_forge2d/src/components/components.dart';
import 'package:plinko_forge2d/src/provider/game_provider.dart';
import 'package:plinko_forge2d/src/widgets/score_card.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import 'plinko_forge2d.dart';
import 'widgets/overlay_screen.dart';

//Most content in this file follows a standard Flutter widget tree build. The parts specific to Flame include using
// GameWidget.controlled to construct and manage the BrickBreaker game instance and the new overlayBuilderMap argument
// to the GameWidget.
//
// This overlayBuilderMap's keys must align with the overlays that the playState setter in BrickBreaker added or removed.
// Attempting to set an overlay that is not in this map leads to unhappy faces all around.

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  static const String routeName = 'GameScreen';

  static Route getRoute(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (_) => MultiProvider(
            providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
            child: const GameApp()));
  }

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  final ScrollController _scrollController = ScrollController();

  late final Plinko plinko;
  late VoidCallback scoreListener;
  late VoidCallback playStateListener;

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
    plinko.playState.removeListener(playStateListener);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.pressStart2pTextTheme().apply(
          bodyColor: const Color(0xff184e77),
          displayColor: const Color(0xff184e77),
        ),
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/bg.jpeg"),
                  fit: BoxFit.cover)),
          child: SafeArea(
            child: Center(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.only(topLeft: Radius.circular(1.0)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.white.withOpacity(0.05),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                          child: Text(
                            'YOUR BET: \$${(context.watch<GameProvider>().totalBet).toInt()}'
                                .toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        ScoreCard(
                            text: "WINNINGS:",
                            total: context
                                .watch<GameProvider>()
                                .roundInfo
                                .totalWinnings),
                        ValueListenableBuilder<List<MoneyMultiplier>>(
                          valueListenable: plinko.gameResults,
                          builder: (context, state, child) {
                            if (_scrollController.hasClients) {
                              //always scroll to the end of list automatically when new items added
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final position = _scrollController.position
                                    .maxScrollExtent; //or minScrollExtent
                                _scrollController.jumpTo(position);
                              });
                            }
                            return SizedBox(
                              height: 30,
                              child: ListView.separated(
                                controller: _scrollController,
                                padding: EdgeInsets.zero,
                                itemCount: state.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (_, index) {
                                  return Container(
                                    color: state[index].color,
                                    height: 20,
                                    width: 35,
                                    child: Center(
                                        child: Text(
                                          "x${state[index].multiplier}",
                                          style: const TextStyle(
                                              fontSize: 7, color: Colors.white),
                                        )),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const SizedBox(
                                    width: 2,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: FittedBox(
                            child: SizedBox(
                              width: gameWidth,
                              height: gameHeight,
                              child: GameWidget(
                                game: plinko,
                                overlayBuilderMap: {
                                  PlayState.roundOver.name: (context, game) {
                                    var roundInfo =
                                        context.read<GameProvider>().roundInfo;
                                    var color = roundInfo.totalBet >
                                        roundInfo.totalWinnings
                                        ? Colors.red
                                        : Colors.amberAccent;
                                    var text = roundInfo.totalBet >
                                        roundInfo.totalWinnings
                                        ? "Y O U    L O S E ! ! !"
                                        : "Y O U    W I N ! ! !";
                                    FlameAudio.play('win.mp3');
                                    return OverlayScreen(
                                      color: color,
                                      title: text,
                                      subtitle: '',
                                      onTap: () {
                                        plinko.setPlayState(PlayState.ready);
                                        plinko.overlays
                                            .remove(PlayState.roundOver.name);
                                      },
                                    );
                                  },
                                  PlayState.gameOver.name: (context, game) {
                                    FlameAudio.play('lose.mp3');
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 8.0),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _roundedTextField("Credit",
                                    context.watch<GameProvider>().credit),
                                _roundedTextFieldWithButtons("Bet",
                                    "\$${context.watch<GameProvider>().bet}",
                                        () {
                                      //on increase bet
                                      if (plinko.getPlayState() ==
                                          PlayState.playing) {
                                        return;
                                      }
                                      plinko.setPlayState(PlayState.ready);

                                      context
                                          .read<GameProvider>()
                                          .increaseBet();
                                      plinko.setPlayState(PlayState.ready);
                                    }, () {
                                      //on decrease bet
                                      if (plinko.getPlayState() ==
                                          PlayState.playing) {
                                        return;
                                      }
                                      plinko.setPlayState(PlayState.ready);
                                      context.read<GameProvider>().decreaseBet();

                                      plinko.setPlayState(PlayState.ready);
                                    }),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ballsSlider(
                                    context.watch<GameProvider>().numberOfBalls,
                                        (count) {
                                      if (plinko.getPlayState() ==
                                          PlayState.playing) {
                                        return;
                                      }
                                      plinko.setPlayState(PlayState.ready);
                                      context.read<GameProvider>().setBalls(count);
                                    }),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  minWidth: 0,
                                  padding: const EdgeInsets.all(0.0),
                                  textColor: Colors.white,
                                  elevation: 16.0,
                                  child: Container(
                                    margin: EdgeInsets.zero,
                                    padding: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/bg.jpeg'),
                                          fit: BoxFit.cover),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        child:
                                        ValueListenableBuilder<PlayState>(
                                          valueListenable: plinko.playState,
                                          builder: (context, state, child) {
                                            return Text(
                                              state == PlayState.playing
                                                  ? "PLAYING"
                                                  : "PLAY",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
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
                                      plinko.playGame(context
                                          .read<GameProvider>()
                                          .roundInfo);
                                    } else {
                                      plinko.setPlayState(PlayState.gameOver);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
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
      Text(title, style: const TextStyle(color: Colors.white)),
      Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
              image: AssetImage('assets/images/bg.jpeg'), fit: BoxFit.cover),
        ),
        child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
      Text("Balls : $value", style: const TextStyle(color: Colors.white)),
      Container(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
      Text(title, style: const TextStyle(color: Colors.white)),
      Container(
        constraints:
        const BoxConstraints(minWidth: 50, maxWidth: 230, maxHeight: 40),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
              image: AssetImage('assets/images/bg.jpeg'), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white),
                  )),
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