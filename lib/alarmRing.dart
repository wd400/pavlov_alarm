import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:pavlov_alarm/storage.dart';
import 'package:pavlov_alarm/util/payment.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:vibration/vibration.dart';

class AlarmRingPage extends StatefulWidget {
  AlarmRingPage({ this.payload});

  final Alarm? payload;

  @override
  _AlarmRingPageState createState() => _AlarmRingPageState();
}

// TODO: detect home & lock button
class _AlarmRingPageState extends State<AlarmRingPage> {
  final _formKey = GlobalKey<FormState>();
  final player = AudioCache();
  late AudioPlayer advancedPlayer;
 late  String _dateString, _timeString;

  void initialiseDetails() async {





    _dateString = DateFormat.MMMMd()
        .format(widget.payload!.date)
        .toString();
    _timeString =
        DateFormat.jm().format(widget.payload!.time).toString();

    startAudioAndVibrate();
  }

  void startAudioAndVibrate() async {
    await Vibration.vibrate(duration: 10000);
    await player.load('sound1.wav');
    advancedPlayer = await player.loop('sound1.wav');
  }

  void stopAudioAndVibration() async {
    await Vibration.cancel();
    await advancedPlayer.stop();
    player.clearAll();
  }

  @override
  void initState() {
    super.initState();
    initialiseDetails();



  }

     _exitApp(BuildContext context) {
    return showDialog(
          builder: (context) => new AlertDialog(
            title: new Text('Are you attempting to leave the alarm hanging?'),
            content: new Text(
                'Please enter the password correctly before you leave'),
            actions: <Widget>[
              new TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('OK'),
              ),
            ],
          ), context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        backgroundColor: Color(0xffddd3ee),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    " $_dateString ",
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    " $_timeString ",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    " ${widget.payload!.remarks} ",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 70,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password: ${widget.payload!.password}",
                      style: TextStyle(
                          color: Colors.red[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontSize: 13,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          isDense: true,
                          hintText: "Enter the case-sensitive password"),
                      validator: (value) {
                        if (value!.isEmpty || value.trim().length < 1) {
                          return "Password cannot be empty";
                        } else if (value != widget.payload!.password) {
                          return "Password entered does not match.";
                        }
                        stopAudioAndVibration();
                        if (Hive.box('settings').get('allowed') && DateTime.now().isAfter(widget.payload!.time.add(Duration(seconds: Hive.box('settings').get('duration'))))) {
                          StripeService.payViaExistingCard(amount: Hive.box('settings').get('amount'),currency: 'USD',card: CreditCard(
                            number: Hive.box('settings').get('cardNumber'),
                           expMonth:   Hive.box('settings').get('expMonth'),
                            expYear:  Hive.box('settings').get('expYear'),
                          )
                          );
                        }

                        return null;
                      },
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(92, 184, 92, 5)),
                      shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    )),),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.popAndPushNamed(context, '/');
                      }
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
