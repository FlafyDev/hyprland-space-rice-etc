import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/notifications_object.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final regionsProvider = StateNotifierProvider<RegionsManager, Map<String, dynamic>>((ref) {
  return RegionsManager();
});

class RegionsManager extends StateNotifier<Map<String, dynamic>> {
  RegionsManager() : super({'volume': false, 'notifications': 0});

  void isVolume(bool onScreen) {
    state = {
      ...state,
      'volume': onScreen,
    };
    const MethodChannel('general').invokeMethod('mouse_regions', state);
  }

  void countNotifications(int count) {
    state = {
      ...state,
      'notifications': count,
    };
    const MethodChannel('general').invokeMethod('mouse_regions', state);
  }
}
