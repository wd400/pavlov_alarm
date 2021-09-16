import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({required this.message, required this.success});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String secret =
      'sk_test_51JX9krDdQq9JVY0E1rV1NLj8X6IqMMnAiuS4LRcWhZgXylIUZbF2gVY6PsbrCYtCFw3IZEBb2fXsugChAMJNaBRP00jFiBOOsD';
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  static init() {

    StripePayment.setOptions(StripeOptions(
        publishableKey: "pk_test_51JX9krDdQq9JVY0EnQOtBgbm2Y4mbGmC5Q8JifYdLYkNhNHoeGTGJGO88rzqf14U8JkrD1ZkWPn5PvVSl7aml0RI00adn9v7ni",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  static Future<StripeTransactionResponse> payViaExistingCard(
      {required String amount, required String currency, required CreditCard card}) async {
    try {
      var paymentMethod = await StripePayment.createPaymentMethod(PaymentMethodRequest(card: card));
      var paymentIntent = await StripeService.createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent!['client_secret'], paymentMethodId: paymentMethod.id));
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(message: 'Transaction successful', success: true);
      } else {
        return new StripeTransactionResponse(message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  payViaExistingCard2( card) async {
      var expiryArr = card['expiryDate'].split('/');
      CreditCard stripeCard = CreditCard(
        number: card['cardNumber'],
        expMonth: int.parse(expiryArr[0]),
        expYear: int.parse(expiryArr[1]),
      );
    StripeTransactionResponse?  response =
      await StripeService.payViaExistingCard(amount: '2500', currency: 'USD', card: stripeCard);

  }

  static Future<StripeTransactionResponse> payWithNewCard({required String amount, required String currency}) async {
    try {
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest());
      var paymentIntent = await StripeService.createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent!['client_secret'], paymentMethodId: paymentMethod.id));
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(message: 'Transaction successful', success: true);
      } else {
        return new StripeTransactionResponse(message: 'Transaction failed', success: false);
      }
    } on PlatformException catch (err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
          message: 'Transaction failed: ${err.toString()}', success: false);
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return new StripeTransactionResponse(message: message, success: false);
  }

  static Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response =
          await http.post(Uri.parse(StripeService.paymentApiUrl), body: body, headers: StripeService.headers);
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }
}
