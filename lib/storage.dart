import 'dart:core';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'storage.g.dart';

@HiveType(typeId: 1)
class Alarm extends HiveObject {
  Alarm({  this.remarks,  required this.date,  required this.time, required this.password, required this.notificationId});

  @HiveField(0)
  String? remarks;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  DateTime time;

  @HiveField(3)
  String password;

  @HiveField(4)
  int notificationId;

}




class Storage {
  static final collection = 'testing';


  static void deleteAlarm(int id) {
    Hive.openBox<Alarm>('alarmBox').then((box) {
      box.delete(id);
    });
  }




  static Future<Alarm?> getAlarmDetails(int id) async {
    Hive.openBox<Alarm>('alarmBox').then((box) {
      return box.get(id);
    });
  }

  static void updateAlarm(int id, Alarm alarm) async {
    Hive.openBox<Alarm>('alarmBox').then((box) {
      return box.put(id,alarm);
    });
  }
}


