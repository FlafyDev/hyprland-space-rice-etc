import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:flutter_background/notifications_object.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final notificationProvider = StateNotifierProvider<NotificationManager, List<NotificationData>>((ref) {
  return NotificationManager();
});

class NotificationData {
  NotificationData({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

class NotificationManager extends StateNotifier<List<NotificationData>> {
  NotificationManager() : super([]) {
    _client = DBusClient.session()
      ..requestName('org.freedesktop.Notifications')
      ..registerObject(
        OrgFreedesktopNotificationsHandler(
          onNotification: _onNotification,
        ),
      );
  }

  late final DBusClient _client;

  void _onNotification(NotificationData notification) {
    state = [
      ...state,
      notification
    ];
  }

  Future<void> closeNotification(int index) async {
    state = [
      ...state
    ]..removeAt(index);
  }
}
