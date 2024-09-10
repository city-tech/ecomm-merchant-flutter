

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
  // final double price = 1000.0;
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late WebViewControllerPlus _controller;
  static double price = 1000;


  @override
  void dispose() {
    // TODO: implement dispose
  

    // _controller.platform.clearCache();
    // _controller.platform.clearLocalStorage();
  
    _controller.removeJavaScriptChannel('Toaster',);
      super.dispose();

   
  }



  // Dynamic HTML content
   String htmlContent = '''
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
        websiteDomain: "http://localhost:3000",
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
   _enableLocalStorageAccess();
    // _configureWebSettings();
    

   
  }

  
  Future<void> _enableLocalStorageAccess() async {
    if (_controller != null) {
      await _controller!.runJavaScriptReturningResult('''
        try {
          window.localStorage.setItem('test', 'value');
          window.localStorage.getItem('test');
        } catch (e) {
          console.error('Failed to access local storage:', e);
        }
      ''');
    }
  }
  
  //  Future<void> _configureWebSettings() async {
  //   if (_controller != null) {
  //     final WebSettings webSettings = await _controller!.getSettings();
  //     await _controller!.runJavaScriptReturningResult('''
  //       try {
  //         window.webSettings = {
  //           javaScriptCanOpenWindowsAutomatically: ${webSettings.javaScriptCanOpenWindowsAutomatically},
  //           supportMultipleWindows: ${webSettings.supportMultipleWindows},
  //           javaScriptEnabled: ${webSettings.javaScriptEnabled},
  //           // Add more WebSettings properties as needed
  //         };
  //       } catch (e) {
  //         console.error('Failed to configure WebSettings:', e);
  //       }
  //     ''');
  //   }
  // }
  

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

        
        
  })
      
      ..loadHtmlString(
        htmlContent,baseUrl:'http://localhost:3000')
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
          onNavigationRequest: (NavigationRequest request){
                if (request.url.startsWith('https://') || request.url.startsWith('http://')) {
        log('Allowing navigation to: ${request.url}');
        return NavigationDecision.navigate;
      } else {
        log('Blocking navigation to: ${request.url}');
        return NavigationDecision.prevent;
      }
  
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
          )..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // This is equivalent to originWhitelist={['*']}
            // It allows navigation to all origins
            return NavigationDecision.navigate;
            
            // If you want to restrict to specific origins, you can use something like:
            // if (request.url.startsWith('https://allowed-domain.com')) {
            //   return NavigationDecision.navigate;
            // }
            // return NavigationDecision.prevent;
          },
        ),
      );
     
  
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout Page'),
      ),
      body: Column(
        
          //  mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60.0,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 241, 235, 179),
              ),
              child: const Center(

                child: Text('TEST Online Store',
                    style: TextStyle(
                        fontSize: 18)
                    ),
              ),
            ),
            const Divider(
              color: Colors.grey, // Customize color
              thickness: 1, // Line thickness
            ),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cart Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                )),
            const SizedBox(height: 20.0),
            const Row(
              children: [
                // Image(image: AssetImage('cup.png'),height: 20.0,width: 20.0),
                Text('Cup Set', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text('Rs 600')
              ],
            ),
            const SizedBox(height: 20.0),
            const Row(
              children: [
                // Image(image: AssetImage('cup.png'),height: 20.0,width: 20.0),
                Text('Speaker', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Text('Rs 400')
              ],
            ),
            const SizedBox(height: 20.0),
            Container(
              height: 30,
              decoration: const BoxDecoration(color: Colors.grey),
              child: const Row(
                children: [
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Spacer(),
                  Text('Rs 1000')
                ],
              ),
            ),
            const SizedBox(height: 18.0),
          Row(
            children: [
              Spacer(),
              Container(
                height: 70,
                width: 110,
                child: WebViewWidget(
                controller: _controller,  
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}
