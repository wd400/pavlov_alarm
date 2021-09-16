import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:pavlov_alarm/util/payment.dart';

class CardsHomePage extends StatefulWidget {
  CardsHomePage() ;

  @override
  CardsHomePageState createState() => CardsHomePageState();
}

class CardsHomePageState extends State<CardsHomePage> {
  onItemPress(BuildContext context, int index) async {
    switch (index) {
      case 0:
        payViaNewCard(context);
        break;
      case 1:
        Navigator.pushNamed(context, '/existing-cards');
        break;
    }
  }

  payViaNewCard(BuildContext context) async {
    StripeTransactionResponse? response;
    pay() async {
     response = await StripeService.payWithNewCard(amount: '15000', currency: 'USD');
    }
    FutureProgressDialog dialog = new FutureProgressDialog(pay(),message:Text( 'Please wait...'));

    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(response!.message),
      duration: new Duration(milliseconds: response!.success == true ? 1200 : 3000),
    ));
  }


  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('SELECT PAYMENT'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.separated(
            itemBuilder: (context, index) {
              late Icon icon;
              late Text text;

              switch (index) {
                case 0:
                  icon = Icon(Icons.add_circle, color: theme.primaryColor);
                  text = Text('Pay via new card');
                  break;
                case 1:
                  icon = Icon(Icons.credit_card, color: theme.primaryColor);
                  text = Text('Pay via existing card');
                  break;
              }

              return InkWell(
                onTap: () {
                  onItemPress(context, index);
                },
                child: ListTile(
                  title: text,
                  leading: icon,
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(
                  color: theme.primaryColor,
                ),
            itemCount: 2),
      ),
    );
  }
}
