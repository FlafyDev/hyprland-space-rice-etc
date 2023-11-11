import 'dart:ui';

import 'package:dbus/dbus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/notifications_object.dart';
import 'package:flutter_background/widgets/background/background.dart';
import 'package:flutter_background/widgets/bar/bar.dart';
import 'package:flutter_background/widgets/foreground/foreground.dart';
import 'package:flutter_background/widgets/notification/notification.dart';
import 'package:flutter_background/widgets/volume/volume.dart';
import 'package:flutter_background/widgets/workspaces_indicator/workspaces_indicator.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  // final client = DBusClient.session();
  // // final object = OrgFreedesktopNotifications(
  // //   client,
  // //   'org.freedesktop.Notifications',
  // //   DBusObjectPath('/org/freedesktop/Notifications'),
  // // );
  // await client.requestName('org.freedesktop.Notifications');
  // await client.registerObject(OrgFreedesktopNotificationsHandler());

  runApp(ProviderScope(child: HookBuilder(
    builder: (context) {
      useOnAppLifecycleStateChange((previous, current) {
        if (current == AppLifecycleState.detached) {
          // client.close();
        }
      });
      return const MyApp();
    },
  )));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        // primaryColor: Colors.white,
        // primaryColorDark: Colors.white,
        scaffoldBackgroundColor: Colors.transparent,
        primarySwatch: Colors.grey,
        sliderTheme: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
          activeTrackColor: Colors.white,
          inactiveTrackColor: Colors.white.withOpacity(0.5),
          thumbColor: Colors.white,
          overlayColor: Colors.white.withOpacity(0.5),
          thumbShape: SliderComponentShape.noThumb,
          trackHeight: 2,
        ),
      ),
      home: Scaffold(
        body: Stack(
          children: [
            // const Background(),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Bar(),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: WorkspacesIndicator(),
            ),
            Foreground(),
            NotificationsViewer(),
          ],
        ),
      ),
    );
  }
}
