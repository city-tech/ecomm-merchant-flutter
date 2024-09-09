// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_bundle_js/payment.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Bundle JS',
//       home: const MyHomePage(title: 'Flutter Bundle JS'),
//       routes: {
//         '/WebViewExample': (context) => WebViewExample(),
//       },
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late WebViewController _controller;
//   final BUNDLE_URL =
//       'https://minio.finpos.global/getpay-cdn/webcheckout/bundle.js';

//     final String htmlContent = '''
//     <html>
//     <body>
//       <h1>Hello from Flutter WebView!</h1>
//       <script>
//         window.addEventListener('message', (event) => {
//           console.log('Message received from Flutter: ', event.data);
//         });
//       </script>
//     </body>
//     </html>
//   ''';

//   @override
//   Widget build(BuildContext context) {

//     Future<void> _launchURL() async {
//       if (await canLaunch(BUNDLE_URL)) {
//         await launch(BUNDLE_URL);
//       } else {
//         throw 'Could not launch $BUNDLE_URL';
//       }
//     }

//     return Scaffold(
//       appBar: AppBar(

//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,

//         title: Text(widget.title),
//       ),
//       body: Center(

//         child: Column(

//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               height: 60.0,
//               decoration: const BoxDecoration(
//                 color: Color.fromARGB(255, 241, 235, 179),
//               ),
//               child: const Center(

//                 child: Text('TEST Online Store',
//                     style: TextStyle(
//                         fontSize: 18)
//                     ),
//               ),
//             ),
//             const Divider(
//               color: Colors.grey, // Customize color
//               thickness: 1, // Line thickness
//             ),
//             const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Cart Items',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
//                 )),
//             const SizedBox(height: 20.0),
//             const Row(
//               children: [
//                 // Image(image: AssetImage('cup.png'),height: 20.0,width: 20.0),
//                 Text('Cup Set', style: TextStyle(fontWeight: FontWeight.bold)),
//                 SizedBox(width: 10),
//                 Text('Rs 379')
//               ],
//             ),
//             const SizedBox(height: 20.0),
//             const Row(
//               children: [
//                 // Image(image: AssetImage('cup.png'),height: 20.0,width: 20.0),
//                 Text('Speaker', style: TextStyle(fontWeight: FontWeight.bold)),
//                 SizedBox(width: 10),
//                 Text('Rs 835')
//               ],
//             ),
//             const SizedBox(height: 20.0),
//             Container(
//               height: 30,
//               decoration: const BoxDecoration(color: Colors.grey),
//               child: const Row(
//                 children: [
//                   Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
//                   SizedBox(width: 10),
//                   Spacer(),
//                   Text('Rs 1214')
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 const Spacer(),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => WebViewExample()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Color.fromARGB(255, 255, 103, 15)),
//                   child: const Text(
//                     'Checkout',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bundle_js/payment.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

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
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(
        htmlContent)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          log('WebView is loading (progress : $progress%)');
        },
        onPageStarted: (String url) {
          log('Page started loading: $url');
        },
        onPageFinished: (String url) {
          log('Page finished loading: $url');
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

      ));
  }

  // Dynamic HTML content
  final String htmlContent = '''
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
            onSuccess: (options) => {
              Toaster.postMessage('success');
            },
            onError: (error) => {
              Toaster.postMessage('error');
            },
          };
          document.getElementById('checkout-btn').onclick = function (e) {
            Toaster.postMessage('startLoading');
            const getPay = new GetPay(options);
            getPay.initialize();
          }
        </script>
      </body>
    </html>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout Page'),
      ),
      body: WebViewWidget(
        controller: _controller
          ..addJavaScriptChannel(
            'Toaster',
            onMessageReceived: (JavaScriptMessage message) {
              if (message.message == "success") {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WebViewExample(),
                  ),
                );
              }
            },
          ),
      ),
    );
  }
}
