import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bundle_js/constants.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late WebViewControllerPlus _controller;
  bool _isLoading = false;
  // final BUNDLE_URL = '${Constants.EXPO_PUBLIC_BUNDLE_URL}';

  final String htmlContent = '''
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"/>
        <title>Your Business Title</title>
        <script defer="defer" src="${Constants.EXPO_PUBLIC_BUNDLE_URL}"></script>
      </head>
      <body>
        <div id="checkout"></div>
      </body>
    </html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _enableLocalStorageAccess(),
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(htmlContent,
          baseUrl: Constants.EXPO_PUBLIC_WEBSITE_DOMAIN)
      // ..clearLocalStorage()
      // ..clearCache()
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          log('WebView is loading (progress : $progress%)');
          _isLoading = true;
        },
        onPageStarted: (String url) {
          log('Page started loading: $url');
          _isLoading = true;
        },
        onPageFinished: (String url) async {
          log('Page finished loading: $url');
          _isLoading = false;
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
          Text(
              'code: -6 description: net::ERR_CONNECTION_REFUSED, errorType: WebResourceErrorType.connect, isForMainFrame: false');
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
      ));
  }

  Future<void> _enableLocalStorageAccess() async {
    await _controller.runJavaScript('''
      try {
        window.localStorage.setItem('test', 'value');
        console.log('localStorage test:', window.localStorage.getItem('test'));
      } catch (e) {
        console.error('Failed to access local storage:', e);
      }
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetPay Checkout'),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
