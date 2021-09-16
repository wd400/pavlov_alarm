import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pavlov_alarm/storage.dart';
import 'package:pavlov_alarm/util/notificationUtil.dart';
import 'package:pavlov_alarm/util/payment.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'addAlarm.dart';
import 'alarmsList.dart';
import 'settings.dart';
import 'alarmRing.dart';
import 'homepage.dart';
import 'package:path_provider/path_provider.dart';

FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future onSelectNotification(String? payload) async {
  await Navigator.push(
    MyApp.navigatorKey.currentState!.context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => AlarmRingPage(payload: Hive.box<Alarm>('alarmBox').get(payload)!),
    ),
  );
}

Future<void> main() async {




  WidgetsFlutterBinding.ensureInitialized();
  await initializeNotifications();
  tz.initializeTimeZones();

  var appDocumentDirectory = await getApplicationDocumentsDirectory();
  print(appDocumentDirectory);
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(AlarmAdapter());
  await Hive.openBox<Alarm>('alarmBox');
  await Hive.openBox('settings');


  StripeService.init();


  runApp(MyApp());
}

class MyApp extends StatelessWidget {



  static final navigatorKey = new GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Alarm',
      home: HomePage(
        title: 'Flutter Alarm',
      ),
      initialRoute: '/',
      routes: {
        '/alarms': (context) => AlarmsListPage(),
        '/addAlarm': (context) => AddAlarmPage(),
        '/settings': (context) => SettingsPage(),
        '/ring': (context) => AlarmRingPage(payload: null,)
      },
      navigatorKey: navigatorKey,
      theme: ThemeData(
        fontFamily: 'JosefinSans',
      ),
    );
  }
}
