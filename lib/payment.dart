import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late WebViewController _controller;
  final BUNDLE_URL = 'https://minio.finpos.global/getpay-cdn/webcheckout/bundle.js';

  final String htmlContent = '''
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"/>
        <title>Your Business Title</title>
        <script defer="defer" src="https://minio.finpos.global/getpay-cdn/webcheckout/bundle.js"></script>
      </head>
      <body>
        <div id="checkout"></div>
      </body>
    </html>
  ''';

  

  @override
  void initState() {
    super.initState();
   _controller= WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)..loadHtmlString(htmlContent);
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetPay Checkout'),
        
      ),
      body: WebViewWidget(

          controller :_controller
      ),
    );
  }
}