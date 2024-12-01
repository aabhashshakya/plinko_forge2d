///Created by Aabhash Shakya on 12/1/24
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const _sound = "sound";


  static late SharedPreferences preferences;

  //call only once in main()
  static Future<SharedPreferences> init() async {
    preferences = await SharedPreferences.getInstance();
    return preferences;
  }

  static Future<bool> setSoundEnabled(bool enabled) async {
    return await preferences.setBool(_sound, enabled);
  }

  static bool isSoundEnabled() {
    return (preferences.getBool(_sound)==null) ? true : preferences.getBool(_sound)!;
  }

}
