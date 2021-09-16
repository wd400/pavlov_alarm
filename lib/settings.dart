import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'card_input.dart';

class SettingsPage extends StatelessWidget {

  final TextEditingController _textFieldController = TextEditingController();



  _displayAmountDialog(BuildContext context) async {
    _textFieldController.clear();
   showDialog(
  context: context,
  builder: (context) {
  return AlertDialog(
  title: Text('What is your Lucky Number'),
  content: TextField(
  controller: _textFieldController,
  textInputAction: TextInputAction.go,
  keyboardType: TextInputType.numberWithOptions(),
  decoration: InputDecoration(hintText: (Hive.box('settings').get('amount')??0).toString(),
      suffixText:'USD'),
  ),
  actions: <Widget>[
  new TextButton(
  child: new Text('Submit'),
  onPressed: () {
    Hive.box('settings').put('amount', int.parse(_textFieldController.value.text));
  Navigator.of(context).pop();
  },
  )
  ],
  );
  });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF1F8FF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 15),
            child: ListView(padding: const EdgeInsets.all(0.0), children: [
              Padding(
                padding: EdgeInsets.only(top: 40, left: 20, bottom: 12),
                child: Text(
                  "Settings",
                  style: TextStyle(fontSize: 26),
                ),
              ),

              MySwitch(),
              ValueListenableBuilder(
              valueListenable: Hive.box('settings').listenable(),
    builder: (context, Box box, _) {
              return ListTile(
                title: Text("Amount"),
                trailing: Text((box.get('amount')??0).toString()+'USD'),
                leading: Icon(
                  Icons.money_sharp,
                  size: 18,
                  color: Color(0xff872EF9),
                ),
                onTap: () {
                  //TODO:open new window
                  print("tapped");
                  _displayAmountDialog(context);
                },
              );})
              ,
    ValueListenableBuilder(
    valueListenable: Hive.box('settings').listenable(),
    builder: (context, Box box, _) {
     Duration _duration= Duration(seconds: box.get('duration')??0);
     int minutes=_duration.inMinutes;
     int seconds=_duration.inSeconds-60*minutes;
           return   ListTile(
trailing: Text( '${minutes}m ${seconds}s' ),
                title: Text("Time before punishment"),
                leading: Icon(
                  Icons.timer,
                  size: 18,
                  color: Color(0xff872EF9),
                ),
                onTap: () {
      //TODO:open new window
      print("tappeddddddd");


      showPicker(context);


      });

                },
              ),

              ListTile(
                title: Text("Credit card"),
                leading: Icon(
                  Icons.credit_card,
                  size: 18,
                  color: Color(0xffFA1FCA),
                ),
                onTap: () async {
    /*
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MySample()),
                  );

                   */
                  // PlatformException(IllegalArgumentException, null, null, null)
    var response= await StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest());
    Hive.box('settings').put('cardNumber',response.card?.number);
    Hive.box('settings').put('expMonth',response.card?.expMonth);
    Hive.box('settings').put('expYear',response.card?.expYear);
                },


              ),
            ]),
          ),
        ),
      ),
    );
  }

  void showPicker(BuildContext context) {

    Picker(
      adapter: NumberPickerAdapter(data: <NumberPickerColumn>[
        //          const NumberPickerColumn(begin: 0, end: 999, suffix: Text(' hours')),
        const NumberPickerColumn(begin: 0, end: 60, suffix: Text(' minutes'), jump: 1),
        const NumberPickerColumn(begin: 0, end: 60, suffix: Text(' seconds'),jump:1),
      ]),
      delimiter: <PickerDelimiter>[
        PickerDelimiter(
          child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Icon(Icons.more_vert),
          ),
        )
      ],
      hideHeader: true,
      confirmText: 'OK',
      confirmTextStyle: TextStyle(inherit: false, color: Colors.red, fontSize: 22),
      title: const Text('Select duration'),
      selectedTextStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List<int> value) {
        // You get your duration here
        int _duration = Duration( minutes: picker.getSelectedValues()[0],
        seconds: picker.getSelectedValues()[1]).inSeconds;
        Hive.box('settings').put('duration',_duration);
      },
    ).showDialog(context);



  }
}

class MySwitch extends  StatefulWidget {
  @override
    _MySwitchState createState() => new _MySwitchState();

}

class _MySwitchState extends State<MySwitch> {
  @override
  Widget build(BuildContext context) {
    return new SwitchListTile(
      title: Text("Activate automatic withdrawal"),
      secondary: Icon(
        Icons.phone,
        size: 18,
        color: Color(0xff0785CC),
      ),
      value: Hive.box('settings').get('allowed') ?? false,
      onChanged: (bool value) {
        Hive.box('settings').put('allowed', value);
        setState(() {

        });
      },
    );
  }

}
