///Created by Aabhash Shakya on 11/11/24
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//different from value notiify as it will always notify when set value is called even if value is changed
//useful in out context when we hit the 0.5 money multiplier multiple time a row, so we set
// AlwaysNotifyValueNotifier<int> = 0.5
//it will always notify even in 0.5 is same as previous, ValueNotifier default wont
class AlwaysNotifyValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  AlwaysNotifyValueNotifier(this._value) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  @override
  T get value => _value;
  T _value;
  set value(T newValue) {
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}