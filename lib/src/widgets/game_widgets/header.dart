///Created by Aabhash Shakya on 11/28/24
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:plinko_forge2d/src/flame/plinko_forge2d.dart';
import 'package:provider/provider.dart';

import '../../provider/game_provider.dart';
import '../outlined_text.dart';

class Header extends StatelessWidget {
  const Header(
      {super.key,
      required this.betAmount,
      required this.totalWinnings,
      required this.playState});

  final int betAmount;
  final int totalWinnings;
  final PlayState playState;

  @override
  Widget build(BuildContext context) {
    var header = switch (playState) {
      PlayState.ready => "PLAY $betAmount COINS",
      PlayState.playing => "PLAYING",
      PlayState.roundOver => context.read<GameProvider>().roundInfo.totalWinnings >
              context.read<GameProvider>().roundInfo.totalBet
          ? "YOU WON $totalWinnings COINS"
          : "BETTER LUCK NEXT TIME",
      PlayState.gameOver => "PLAY $betAmount COINS",
    };

    return Container(
      padding: EdgeInsetsDirectional.only(
          start: 4.w, end: 4.w, top: 12.h, bottom: 16.h),
      width: double.maxFinite,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/header.png"), fit: BoxFit.fill)),
      child: Center(
        child: FittedBox(
          child: OutlinedText(
            text: header,
          ),
        ),
      ),
    );
  }
}
