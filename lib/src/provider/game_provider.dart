///Created by Aabhash Shakya on 10/18/24
import 'package:flutter/material.dart';

import '../constants/config.dart';
import '../model/round_info.dart';

class GameProvider extends ChangeNotifier {
  var credit = defaultCredit;
  var numberOfBalls = minBalls;
  var bet = minBet;
  var maxBet = 1000;
  late int totalBet;

  RoundInfo roundInfo = RoundInfo.getDefault();

  GameProvider() {
    totalBet = bet * numberOfBalls;
  }

  void updateTotalWinnings(num score) {
    roundInfo.updateTotalWinnings(score);
    credit += (roundInfo.bet * score).toInt();
    notifyListeners();
  }

  int calculateMissingCredits() {
    return (bet * numberOfBalls) - credit;
  }

  int setBet(value) {
    if (value > credit || value + 10 > credit) {
      return bet;
    }
    bet = value;
    totalBet = numberOfBalls * bet;
    notifyListeners();
    return bet;
  }

  int increaseBet() {
    if (bet >= credit || bet + 10 > credit) {
      return bet;
    }
    bet = bet + 10;
    totalBet = numberOfBalls * bet;
    notifyListeners();
    return bet;
  }

  int decreaseBet() {
    if (bet == 0 || bet - 10 == 0) {
      return bet;
    }
    bet = bet - 10;
    totalBet = numberOfBalls * bet;
    notifyListeners();
    return bet;
  }

  int setBalls(int value) {
    numberOfBalls = value;
    totalBet = numberOfBalls * bet;
    notifyListeners();
    return numberOfBalls;
  }

  int increaseBalls() {
    if (numberOfBalls >= maxBalls) {
      return bet;
    }
    numberOfBalls++;
    totalBet = numberOfBalls * bet;

    notifyListeners();
    return numberOfBalls;
  }

  int decreaseBalls() {
    if (numberOfBalls <= minBalls) {
      return bet;
    }
    numberOfBalls--;
    totalBet = numberOfBalls * bet;
    notifyListeners();
    return numberOfBalls;
  }

  bool trySpendCredits() {
    if (bet * numberOfBalls <= credit) {
      roundInfo.reset();
      roundInfo.setBet(bet);
      roundInfo.setBalls(numberOfBalls);
      credit = credit - (bet * numberOfBalls);

      notifyListeners();
      return true;
    }
    return false;
  }
}
