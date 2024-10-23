///Created by Aabhash Shakya on 10/18/24
import 'package:flutter/material.dart';
import 'package:plinko_forge2d/config.dart';

import '../components/components.dart';

class RoundInfo extends ChangeNotifier {
  RoundInfo._(this.bet, this.balls, this.totalBet, this.totalWinnings,
      this.results, this.isSimulation);

  int bet;
  int totalBet;
  int balls;
  int totalWinnings;
  List<MoneyMultiplier> results;
  bool isSimulation;

  static RoundInfo getDefault() {
    return RoundInfo._(minBet, minBet * minBalls, minBalls, 0, [],false);
  }

  void setBet(int value) {
    bet = value;
    totalBet = bet * balls;
    notifyListeners();
  }

  void setBalls(int value) {
    balls = value;
    totalBet = bet * balls;
    notifyListeners();
  }

  void updateTotalWinnings(num score) {
    totalWinnings += (score * bet).toInt();
    notifyListeners();
  }

  void setResults(List<MoneyMultiplier> value) {
    results = value;
    notifyListeners();
  }

  void reset() {
    isSimulation = false;
    totalWinnings = 0;
    results = [];
  }
}
