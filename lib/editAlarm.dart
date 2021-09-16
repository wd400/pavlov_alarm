
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:pavlov_alarm/util/notificationUtil.dart';
import 'package:pavlov_alarm/util/widgetsUtil.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'storage.dart';
import 'main.dart';

class EditAlarmPage extends StatefulWidget {
  EditAlarmPage({ required this.document}) ;

  final Alarm document;

  @override
  _EditAlarmPageState createState() => _EditAlarmPageState();
}

class _EditAlarmPageState extends State<EditAlarmPage> {
  final _formKey = GlobalKey<FormState>();
   String? dateString,timeString;
  late DateTime currentDate;
  late String currentPassword;
  late DateTime currentTime;
   String? currentRemarks;

  void inititaliseDetails() async {

    currentDate=widget.document.date;
    currentPassword=widget.document.password;
    currentTime=widget.document.time;
    currentRemarks=widget.document.remarks;
    currentPassword=widget.document.password;

    dateString = DateFormat.MMMMd()
        .format(widget.document.date)
        .toString();
    timeString =
        DateFormat.jm().format(widget.document.time).toString();

  }

  @override
  void initState() {
    super.initState();
    inititaliseDetails();
  }

  Future<void> callback(docId, notificationId, {remarks}) async {
    var now = tz.TZDateTime.now(
            tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()))
        .add(Duration(seconds: 10));
    cancelAlarm(notificationId);
    print('remarks '+remarks.toString());
    print('notificationId '+notificationId.toString());
    print('docId '+docId.toString());
    await singleNotification(localNotificationsPlugin, now, "Flutter alarm",
        '', notificationId, docId.toString());
  }

  void onChangePassword(value) => {
        setState(() {
          currentPassword = value;
        })
      };

  void onChangedRemarks(value) => {
        setState(() {
          currentRemarks = value;
        })
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF1F8FF),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20.0,
                        ),
                        TextButton(
                          onPressed: () {
                            DatePicker.showDatePicker(
                              context,
                              showTitleActions: true,
                              onConfirm: (date) {
                                setState(() {
                                 currentDate = date;
                                  dateString = DateFormat.MMMMd()
                                      .format(date)
                                      .toString();
                                });
                              },
                              minTime: DateTime.now(),
                              maxTime: DateTime.now().add(Duration(days: 14)),
                            );
                          },
                          child: Text(
                            dateString ??
                                DateFormat.MMMMd()
                                    .format(DateTime.now())
                                    .toString(),
                            style:
                                TextStyle(color: Colors.blueGrey, fontSize: 18),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            DatePicker.showTimePicker(
                              context,
                              showTitleActions: true,
                              onConfirm: (time) {
                                setState(() {
                                  currentTime = time;
                                  timeString =
                                      DateFormat.jm().format(currentTime).toString();
                                });
                              },
                              showSecondsColumn: false,
                            );
                          },
                          child: Text(
                            timeString ??
                                DateFormat.jm()
                                    .format(DateTime.now())
                                    .toString(),
                            style: TextStyle(color: Colors.amber, fontSize: 60),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Column(
                            children: [
                              buildRemarksField(onChangedRemarks,
                                  initialValue: currentRemarks??''),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: buildPasswordField(onChangePassword,
                                    initialValue: currentPassword),
                              ),
                              buildPasswordRules(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.green),
                                  borderRadius: BorderRadius.circular(15.0)),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  int notificationId = Random().nextInt(1000);

                                  widget.document.password=currentPassword;
                                  widget.document.remarks=currentRemarks;
                                  widget.document.time=currentTime;
                                  widget.document.date=currentDate;
                                  widget.document.notificationId=notificationId;
                                  widget.document.save();

                                  callback(widget.document.key, notificationId,remarks: currentRemarks);
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                'Update',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            buildCancelButton(context),
                          ],
                        ),
                      ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
