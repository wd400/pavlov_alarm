import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pavlov_alarm/util/notificationUtil.dart';
import 'package:pavlov_alarm/util/receivedNotification.dart';
import 'alarmRing.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'editAlarm.dart';
import 'storage.dart';

class AlarmsListPage extends StatefulWidget {
  AlarmsListPage() ;

  @override
  _AlarmsListPageState createState() => _AlarmsListPageState();
}

class _AlarmsListPageState extends State<AlarmsListPage> {
   String? _time;
   String? _date;

  @override
  void initState() {
    super.initState();
    Timer.periodic(
        Duration(
          milliseconds: 50,
        ),
        (Timer t) => _getDateTime());
    _configureSelectNotificationSubject();
    _configureDidReceiveLocalNotificationSubject();
    requestPermissions();
  }

  void _getDateTime() {
    var _dateTime = new DateTime.now();
    final String formattedDate =
        DateFormat('dd MMM').format(_dateTime).toString();
    final String formattedTime =
        DateFormat('kk:mm').format(_dateTime).toString();
    if (this.mounted) {
      setState(() {
        _time = formattedTime;
        _date = formattedDate;
      });
    }
  }

  Widget _buildListItem(BuildContext context, Alarm document) {
    bool isAfterSix = document.time.hour > 17;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ListTile(
        leading: isAfterSix
            ? Transform.rotate(
                angle: 180 * math.pi / 180,
                child: Icon(
                  Icons.brightness_2_outlined,
                  size: 22,
                  color: Color(0xffA771DE),
                ),
              )
            : Icon(
                Icons.brightness_low_outlined,
                size: 22,
                color: Color(0xffFB81D1),
              ),
        title: Text(
          DateFormat('kk:mm').format(document.time).toString(),
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
        ),
        subtitle: Text(
          document.remarks?? 'No remarks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            size: 24,
          ),
          color: Colors.red[700],
          highlightColor: Colors.amberAccent,
          onPressed: () {
            document.delete();
          },
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      EditAlarmPage(document: document)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF1F8FF),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 65.0, bottom: 5.0),
              child: Text(
                " $_date ",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Text(
              " $_time ",
              style: TextStyle(
                fontSize: 60.0,
                color: Color(0xffFBB500),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushNamed(context, '/addAlarm');
                  },
                  color: Colors.orange[600],
                  highlightColor: Colors.blue[200],
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: Hive.box<Alarm>('alarmBox').listenable(),
              builder: (context, Box<Alarm> _alarmBox, _) {

                return Expanded(
                  child: ListView.builder(
                      itemCount: _alarmBox.values.length,
                      itemBuilder: (context, index) => _buildListItem(
                          context, _alarmBox.getAt(index)!)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((Alarm payload) async {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => AlarmRingPage(payload: payload),
        ),
      );
    });
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        AlarmRingPage(payload:  Hive.box('alarmBox').get(receivedNotification.id)),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }
}
