import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late WebViewController _controller;
  final BUNDLE_URL = 'https://minio.finpos.global/getpay-cdn/webcheckout/bundle.js';
  

  @override
  void initState() {
    super.initState();
    // Enable JavaScript if you're going to use it.
    _controller = WebViewController(
    
    )..loadRequest(Uri.parse(BUNDLE_URL))
    ..setJavaScriptMode(JavaScriptMode.unrestricted);
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