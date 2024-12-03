///Created by Aabhash Shakya on 12/1/24
import 'package:flame_audio/flame_audio.dart';
import 'package:plinko_forge2d/src/constants/shared_prefs.dart';
import 'package:plinko_forge2d/src/model/round_info.dart';

class SoundManager {
  static late AudioPool _collisionPool;
  static late AudioPool _moneyMultiplierPool;
  static DateTime _lastCollisionSoundPlayed = DateTime.now();
  static DateTime _lastMoneyMultiplierSoundPlayed = DateTime.now();

  //call only once in main()
  static Future<void> init() async {
    _collisionPool = await FlameAudio.createPool('bounce.mp3',
        maxPlayers: 3);
    _moneyMultiplierPool =
        await FlameAudio.createPool('win.mp3', maxPlayers: 3);
  }

  static void playCollisionSound() {
    if (SharedPrefs.isSoundEnabled()) {
      var buffer = 90;
      //audio player will crash if we play lots of sound at once, even soundpool
      if (DateTime.now().difference(_lastCollisionSoundPlayed).inMilliseconds > buffer) {
        _collisionPool.start(volume: 0.1);
        _lastCollisionSoundPlayed = DateTime.now();
      }
    }
  }

  static void playMoneyMultiplierSound() {
    if (SharedPrefs.isSoundEnabled()) {
      var buffer = 40;
      //audio player will crash if we play lots of sound at once, even soundpool
      if (DateTime
          .now()
          .difference(_lastMoneyMultiplierSoundPlayed)
          .inMilliseconds > buffer) {
        _moneyMultiplierPool.start(volume: 0.3);
        _lastMoneyMultiplierSoundPlayed = DateTime.now();
      }
    }
  }

  static void playWinSound() {
    if (SharedPrefs.isSoundEnabled()) {
      FlameAudio.play('win.mp3', volume: 0.5);
    }
  }

  static void playLoseSound() {
    if (SharedPrefs.isSoundEnabled()) {
      FlameAudio.play('lose.mp3', volume: 0.5);
    }
  }
}
