import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bundle_js/payment.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'constants.dart' as Constants;

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
 static TextEditingController _amountController = TextEditingController();
  // late AnimationController _animationController;

  @override
  void dispose() {

    _controller.removeJavaScriptChannel(
      'Toaster',
    );
    super.dispose();
  }

  // Dynamic HTML content
   String htmlContent = "";
  @override
  void initState() {
    super.initState();
    // _animationController = AnimationController(
    //   /// [AnimationController]s can be created with `vsync: this` because of
    //   /// [TickerProviderStateMixin].
    //   vsync: this,
    //   duration: const Duration(seconds: 5),
    // )..addListener(() {
    //     setState(() {});
    //   });
   htmlContent = '''
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"/>
    <title>Your Business Title</title>
    <script defer="defer" src="${Constants.Constants.EXPO_PUBLIC_BUNDLE_URL}"></script>
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
        papInfo: "${Constants.Constants.EXPO_PUBLIC_PAP_INFO}",
        oprKey: "${Constants.Constants.EXPO_PUBLIC_OPR_KEY}",
        insKey: "${Constants.Constants.EXPO_PUBLIC_INS_KEY}",
        websiteDomain: "${Constants.Constants.EXPO_PUBLIC_WEBSITE_DOMAIN}",
        price: "1000",  // Replace with your dynamic price calculation
        businessName: "${Constants.Constants.EXPO_PUBLIC_BUSINESS_NAME}",
        imageUrl: "${Constants.Constants.EXPO_PUBLIC_LOGO_URL}",
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
          successUrl: "${Constants.Constants.EXPO_PUBLIC_SUCCESS_URL}",
          failUrl: "${Constants.Constants.EXPO_PUBLIC_FAIL_URL}"
        },
        themeColor: "#5662FF",
     orderInformationUI: \`
          <div style='display: flex; align-items: center; margin-bottom: 10px;'>
            <img style='max-width: 50px; margin-right: 10px;' src='https://media.istockphoto.com/id/821282266/photo/white-mug-isolated.jpg?s=2048x2048&w=is&k=20&c=aMUoxLBq_4VOE5HbYpWebboQNerQzoH4ASAiFjk0R3g=' alt='Cup'>
            <div>
              <p>Cups</p>
              <span>Rs 600</span>
            </div>
            <br>
          </div>
              <div style='display: flex; align-items: center; margin-bottom: 10px;'>
            <img style='max-width: 50px; margin-right: 10px;' src='https://www.artis.in/cdn/shop/products/1_f5b3377c-c870-420f-bc6a-5cd4b3a5a7c7.jpg?v=1653639993' alt='Speaker'>
            <div>
              <p>Speaker</p>
              <span>Rs 400</span>
            </div>\`,
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

    _enableLocalStorageAccess();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

     int counter1 = 1;
     int _counter2 = 1;

     int totalCupPrice = 600;
     int totalSpeakerPrice = 400;

     bool isCup = false;
     bool isSpeaker = false;

  @override
  Widget build(BuildContext context) {
    _controller = WebViewControllerPlus(
      onPermissionRequest: (request) {
        request.platform.grant();
      },
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted).then((value) async {})
      ..loadHtmlString(htmlContent, baseUrl: 'http://localhost:3000')
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          log('WebView is loading (progress : $progress%)');
        },
        onPageStarted: (String url) {
          log('Page started loading: $url');
        },
        onPageFinished: (String url) async {
          log('Page finished loading: $url');
          if (Platform.isAndroid) {}
        },
        onWebResourceError: (WebResourceError error) {
          log('''
                Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
                ''');
                Text('code: -6 description: net::ERR_CONNECTION_REFUSED, errorType: WebResourceErrorType.connect, isForMainFrame: false');
        },
        onHttpError: (HttpResponseError error) {
          log('Error occurred on page: ${error.response?.statusCode}');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://') ||
              request.url.startsWith('http://')) {
            log('Allowing navigation to: ${request.url}');
            return NavigationDecision.navigate;
          } else {
            log('Blocking navigation to: ${request.url}');
            return NavigationDecision.prevent;
          }
        },
      ))
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          print('message trigged' + message.toString());
          if (message.message == "success") {
            print('buton clicked');

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => WebViewExample(),
              ),
            );
          } else {
            print(message.message.toString());
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // This is equivalent to originWhitelist={['*']}
            // It allows navigation to all origins
            return NavigationDecision.navigate;
          },
        ),
      );

    return Scaffold(
        appBar: AppBar(
          title: Text('Checkout Page'),
        ),
        body: Column(
          children: [
            Container(
              height: 60.0,
              
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 241, 235, 179),
              ),
              child: const Center(
                child:
                    Text('TEST Online Store', style: TextStyle(fontSize: 18)),
              ),
            ),
            const Divider(
              color: Colors.grey, 
              thickness: 1, 
            ),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cart Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                )),
            const SizedBox(height: 20.0),
            ListTile(
              
              leading: Container(
               
                child:  Image.asset('assets/cup.png'),
                height: 60,
              width: 60,
              ),
                    
               title: Text('Cup Set', style: TextStyle(fontWeight: FontWeight.bold)),
            
                subtitle: Column(
                       mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rs 600'),
                    Divider(),
                    Text("Total: ${calculateTotalEachCup(count: counter1,price: 600)}")

                  ],
                ),
                trailing: Container(
                  height: 100,
                  child: itemCounter1()),
            
            ),
              ListTile(
              leading: Container(
                  child:  Image.asset('assets/speaker.png'),
              
                height: 60,
              width: 60,
              ),
        
               title: Text('Speaker', style: TextStyle(fontWeight: FontWeight.bold)),
            
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rs 400'),
                                 Divider(),
                    Text("Total: ${calculateTotalEachSpeaker(count: _counter2,price: 400)}")
                  ],
                ),
                trailing: itemCounter2(),
            
            ),
            const SizedBox(height: 20.0),
      
             SizedBox(height: 20.0),
            Container(
              height: 60,
              decoration: const BoxDecoration(color: Colors.grey),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
               const  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 90 ,
                    child: Text(calculateGrandTotal().toString())
                  ),
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
        ));
  }

 Widget itemCounter1(){
  return Container(
    width: 140,
    height: 100,
    child: Row(children: [
      Card(child: IconButton(onPressed: (){
        setState(() {
          counter1+=1;
        });
      }, icon: Icon(Icons.add))),
      Text(counter1.toString()),
         Card(child: IconButton(onPressed: (){
          setState(() {
            if(counter1 >1){
                  counter1 -=1;
            }
          });
     
         }, icon: Icon(Icons.remove)))
    ],),
  );

  }

  int totalGrand = 1000;
int calculateGrandTotal(){
  
totalGrand = totalCupPrice + totalSpeakerPrice;
  return totalGrand;


}





  int calculateTotalEachCup({required int count,required int price,}){
   int totalEach  = price * count;
  
    totalCupPrice = totalEach;
   
   return totalEach;


  }



  int calculateTotalEachSpeaker({required int count,required int price}){
   int totalEach  = price * count;

    totalSpeakerPrice = totalEach;
  
   return totalEach;


  }

 Widget itemCounter2(){
  return Container(
    width: 150,
    height: 100,
    child: Row(children: [
      Card(child: IconButton(onPressed: (){
        setState(() {
          _counter2+=1;
        });
      }, icon: Icon(Icons.add))),
      Text(_counter2.toString()),
         Card(child: IconButton(onPressed: (){
          setState(() {
            if(_counter2 >1){
                  _counter2 -=1;
            }
          });
     
         }, icon: Icon(Icons.remove)))
    ],),
  );

  }
}
