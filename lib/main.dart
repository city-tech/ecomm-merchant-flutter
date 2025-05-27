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
    checkoutParameters.bank = "LIVE";
    checkoutParameters.requestNumber = "1234567890";
    checkoutParameters.currency = "NPR";
    checkoutParameters.customSuccessHtml = Constants.EXPO_PUBLIC_SUCCESS_URL;
    checkoutParameters.customFailureHtml = Constants.EXPO_PUBLIC_FAIL_URL;

//commented for now, uncomment if you want to use custom succes and failure page
    // checkoutParameters.customSuccessHtml = '''
    //   <!DOCTYPE html>
    //   <html lang="en">
    //   <head>
    //     <meta charset="UTF-8">
    //     <meta name="viewport" content="width=device-width, initial-scale=1.0">
    //     <title>Custom Success</title>
    //     <style>
    //       body { font-family: Arial; background-color: #e8f5e9; padding: 20px; }
    //       .container { max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
    //       h1 { color: #2e7d32; text-align: center; }
    //       .btn { display: inline-block; background-color: #2e7d32; color: white; padding: 12px 24px; border-radius: 5px; text-decoration: none; margin-top: 20px; }
    //     </style>
    //   </head>
    //   <body>
    //     <div class="container">
    //       <h1>Payment Successful!</h1>
    //       <p>Thank you for your purchase. Your order has been confirmed.</p>
    //       <p>Order #: <strong>${checkoutParameters.requestNumber}</strong></p>
    //       <p>Amount: <strong>${checkoutParameters.currency} ${checkoutParameters.amount}</strong></p>
    //       <a id="btn" class="btn">Continue</a>
    //     </div>
    //     <script>
    //       document.getElementById("btn").addEventListener("click", function() {
    //         window.Toaster.postMessage("success");
    //       });
    //     </script>
    //   </body>
    //   </html>
    // ''';

    // checkoutParameters.customFailureHtml = '''
    //   <!DOCTYPE html>
    //   <html lang="en">
    //   <head>
    //     <meta charset="UTF-8">
    //     <meta name="viewport" content="width=device-width, initial-scale=1.0">
    //     <title>Custom Failure</title>
    //     <style>
    //       body { font-family: Arial; background-color: #ffebee; padding: 20px; }
    //       .container { max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
    //       h1 { color: #c62828; text-align: center; }
    //       .btn { display: inline-block; background-color: #c62828; color: white; padding: 12px 24px; border-radius: 5px; text-decoration: none; margin-top: 20px; }
    //     </style>
    //   </head>
    //   <body>
    //     <div class="container">
    //       <h1>Payment Failed</h1>
    //       <p>We couldn't process your payment. Please try again or contact support.</p>
    //       <a id="btn" class="btn">Try Again</a>
    //     </div>
    //     <script>
    //       document.getElementById("btn").addEventListener("click", function() {
    //         window.Toaster.postMessage("error");
    //       });
    //     </script>
    //   </body>
    //   </html>
    // ''';

    checkoutParameters.onSuccess = (message) {
      debugPrint('ON CHECKOUT SUCCESS $message');
    };
    checkoutParameters.onFailure = (errorMessage) {
      debugPrint('ON CHECKOUT ERROR $errorMessage');
    };
    return checkoutParameters;
  }
}
