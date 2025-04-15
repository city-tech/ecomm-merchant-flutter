import 'package:ecomm_merchant_demo/checkout_page.dart';
import 'package:ecomm_merchant_demo/checkout_parameters.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: CheckoutPage(prepareCheckoutParameters()),
    );
  }

  CheckoutParameters prepareCheckoutParameters() {
    CheckoutParameters checkoutParameters = CheckoutParameters();
    checkoutParameters.merchantName = "JPT Demo";
    checkoutParameters.papInfo = Constants.EXPO_PUBLIC_PAP_INFO;
    checkoutParameters.secretKey = Constants.EXPO_PUBLIC_OPR_KEY;
    checkoutParameters.amount = 1200.00;
    checkoutParameters.businessName = "JPT Demo";
    checkoutParameters.logoUrl = Constants.EXPO_PUBLIC_LOGO_URL;
    checkoutParameters.bank = "QA";
    checkoutParameters.requestNumber = "1234567890";
    checkoutParameters.currency = "NPR";
    checkoutParameters.onSuccess = (message) {
      debugPrint('ON CHECKOUT SUCCESS $message');
    };
    checkoutParameters.onFailure = (errorMessage) {
      debugPrint('ON CHECKOUT ERROR $errorMessage');
    };
    return checkoutParameters;
  }
}
