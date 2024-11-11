///Created by Aabhash Shakya on 11/11/24
import 'package:flutter/material.dart';

//different from value notiify as it will always notify when set value is called even if value is changed
//useful in out context when we hit the 0.5 money multiplier multiple time a row, so we set
// AlwaysNotifyValueNotifier<int> = 0.5
//it will always notify even in 0.5 is same as previous, ValueNotifier default wont
class AlwaysNotifyValueNotifier<T> extends ValueNotifier<T> {
  AlwaysNotifyValueNotifier(super.value);

  @override
  set value(T newValue) {
    super.value = newValue;
    notifyListeners(); // Always notify, even if value hasn't changed
  }
}