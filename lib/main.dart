

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bundle_js/payment.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter WebView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CheckoutPage(),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late WebViewControllerPlus _controller;


  @override
  void dispose() {
    // TODO: implement dispose
  

    _controller.platform.clearCache();
    _controller.platform.clearLocalStorage();
  
    _controller.removeJavaScriptChannel('Toaster',);
      super.dispose();

   
  }



  // Dynamic HTML content
   String htmlContent = '''
  <!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"/>
    <title>Your Business Title</title>
    <script defer="defer" src="https://minio.finpos.global/getpay-cdn/webcheckout/bundle.js"></script>
    <style>
      #checkout-btn {
          display: block;
          text-align: center;
          margin-bottom: 1em;
          font-size: 1.25em;
          padding: 1em;
          cursor: pointer;
          background-color: burlywood;
          border-radius: .33rem;
          border-color: var(--wp--preset--color--contrast);
          border-width: 0;
          color: var(--wp--preset--color--base);
          font-family: inherit;
          font-size: var(--wp--preset--font-size--small);
          font-style: normal;
          font-weight: 500;
          line-height: inherit;
          text-decoration: none;
      }
    </style>
  </head>
  <body>
    <div id="checkout" hidden></div>
    <button id="checkout-btn">Checkout</button>
    <script type="text/javascript">
      // Set options for GetPay checkout
      const options = {
        userInfo: {
          name: "John Doe",
          email: "john@gmail.com",
          state: "Bagmati",
          country: "Nepal",
          zipcode: "44600",
          city: "Kathmandu",
          address: "Chabahil",
        },
        papInfo: "eyJpbnN0aXR1dGlvbklkIjoiMDAwIiwibWlkIjoiMTIxMjEyMTIxMjEyMTIxIiwidGlkIjoiMTIzNDU2NzgifQ==",
        oprKey: "4fa4c6b9-3f91-43e5-9b4f-319f68187ba5",
        insKey: "000",
        websiteDomain: "http://localhost",
        price: "1000",  // Replace with your dynamic price calculation
        businessName: "OneStop Shopping - Kathmandu",
        imageUrl: "IMAGE_URL",
        currency: "NPR",
        prefill: {
          name: true,
          email: true,
          state: true,
          city: true,
          address: true,
          zipcode: true,
          country: true
        },
        disableFields: {
          address: true,
          state: true
        },
        callbackUrl: {
          successUrl: "SUCCESS_URL",
          failUrl: "FAIL_URL"
        },
        themeColor: "#5662FF",
        orderInformationUI: "<p>Order details here</p>",
        // Handle success response
        onSuccess: (response) => {
          Toaster.postMessage("success");  // No need for window.onload here
        },
        // Handle error response
        onError: (error) => {
          Toaster.postMessage("error");  // No need for window.onload here
        },
      };

      // Checkout button click handler
      document.getElementById('checkout-btn').onclick = function (e) {
        // Notify Flutter that the loading has started
         if (window.Toaster) {
    window.Toaster.postMessage("success");
  } else {
    console.log("Toaster channel is not available.");
  }
   window.Toaster.postMessage("success");

        // Initialize GetPay with the given options
        const getPay = new GetPay(options);
        getPay.initialize();
      };
    </script>
  </body>
</html>

  ''';


    @override
  void initState() {
    super.initState();
  
   
  }

  

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    
  }

  @override
  Widget build(BuildContext context) {
     _controller = WebViewControllerPlus(
         onPermissionRequest: (request) {
    request.platform.grant();
    
    },
     )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      .then((value)async {
     
        
      await _controller.runJavaScript(   
        "window.localStorage.setItem('access_token','  Bearer token');",
      );})
      ..loadHtmlString(
        htmlContent)..clearLocalStorage()..clearCache()
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          log('WebView is loading (progress : $progress%)');
        },
        onPageStarted: (String url) {
          log('Page started loading: $url');
          
        },
        onPageFinished: (String url) async{
          log('Page finished loading: $url');
               if (Platform.isAndroid) {
  
}
        },
        onWebResourceError: (WebResourceError error) {
          log('''
                Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
                ''');
        },
        onHttpError: (HttpResponseError error) {
            log('Error occurred on page: ${error.response?.statusCode}');
          },

      ))..addJavaScriptChannel(
            'Toaster',
            onMessageReceived: (JavaScriptMessage message) {
              
              print('message trigged'+ message.toString());
              if (message.message == "success") {
                print('buton clicked');
             
         
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => WebViewExample(),
                  ),
                );
              }else{
                print(message.message.toString());
              }
            },
          );
     
  
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout Page'),
      ),
      body: WebViewWidget(
      
        controller: _controller,
      
        
       
      )
    );
  }
}
