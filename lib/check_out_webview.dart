// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'dart:convert';

// class MyWebView extends StatefulWidget {
//   @override
//   _MyWebViewState createState() => _MyWebViewState();
// }

// class _MyWebViewState extends State<MyWebView> {
//   late WebViewController _controller;

//   // Example HTML content to load
//   final String htmlContent = '''
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
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('WebView in Flutter'),
//       ),
//       body: WebViewWidget(
//         controller: _controller,
//         initialUrl: Uri.dataFromString(
//           htmlContent,
//           mimeType: 'text/html',
//           encoding: Encoding.getByName('utf-8'),
//         ).toString(),
//         javascriptMode: JavascriptMode.unrestricted,  // Enable JavaScript
//         onWebViewCreated: (WebViewController webViewController) {
//           _controller = webViewController;
//         },
//         javascriptChannels: <JavascriptChannel>{
//           _toFlutterJavascriptChannel(context),  // Handle messages from WebView
//         },
//         onPageStarted: (String url) {
//           print('Page loading started');
//         },
//         onPageFinished: (String url) {
//           print('Page loading finished');
//         },
//       ),
//     );
//   }

// }
