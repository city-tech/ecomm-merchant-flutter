import 'package:ecomm_merchant_demo/checkout_html.dart';
import 'package:ecomm_merchant_demo/checkout_parameters.dart';
import 'package:ecomm_merchant_demo/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'constants.dart';
export 'package:ecomm_merchant_demo/checkout_page.dart';

class CheckoutPage extends StatefulWidget {
  final CheckoutParameters _checkoutParameters;

  const CheckoutPage(this._checkoutParameters, {super.key});

  @override
  _CheckoutPage createState() => _CheckoutPage(_checkoutParameters);
}

class _CheckoutPage extends State<CheckoutPage> {
  WebViewController? _checkoutWbController;
  CheckoutParameters _checkoutParameters;

  _CheckoutPage(this._checkoutParameters);

  @override
  void initState() {
    debugPrint("Checkout Page initState called");
    _initializeCheckoutWbController();
    _enableLocalStorageAccess();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checking Out...')),
      body: Center(child: WebViewWidget(controller: _checkoutWbController!)),
    );
  }

  void _initializeCheckoutWbController() {
    _checkoutWbController =
        WebViewController(
            onPermissionRequest: (request) {
              request.platform.grant();
            },
          )
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'Toaster',
            onMessageReceived: (JavaScriptMessage message) {
              debugPrint('Message Received $message');
              if (message.message.toLowerCase() == "success") {
                debugPrint('SUCCESS MESSAGE RECEIVED');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(_checkoutParameters),
                  ),
                );
              } else {
                _checkoutParameters.onFailure(message.message);
              }
            },
          )
          ..loadHtmlString(
            CheckoutHtml().checkoutWithParameters(
              _checkoutParameters.merchantName,
              _checkoutParameters.papInfo,
              _checkoutParameters.secretKey,
              _checkoutParameters.institutionKey != null
                  ? _checkoutParameters.institutionKey!
                  : '',
              _checkoutParameters.websiteDomain != null
                  ? _checkoutParameters.websiteDomain!
                  : Constants.EXPO_PUBLIC_WEBSITE_DOMAIN,
              _checkoutParameters.amount,
              _checkoutParameters.businessName,
              _checkoutParameters.logoUrl,
              _checkoutParameters.bank,
              _checkoutParameters.requestNumber,
              _checkoutParameters.currency,
            ),
            // CheckoutHtml.checkoutScript,
            baseUrl: Constants.EXPO_PUBLIC_WEBSITE_DOMAIN,
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                debugPrint('WebView is loading (Progress == $progress)');
              },
              onPageStarted: (String url) {
                debugPrint('PAGE WITH URL $url STARTED');
              },
              onPageFinished: (String url) {
                debugPrint('PAGE WITH URL $url FINISHED');
              },
              onWebResourceError: (WebResourceError error) {
                String message =
                    'Page Load Error: Code = ${error.errorCode}, Description = ${error.description}';
                debugPrint(message);
                _checkoutParameters.onFailure(message);
              },
              onHttpError: (HttpResponseError error) {
                String message =
                    'Page Load HTTP Error: Code = ${error.response?.statusCode}';
                debugPrint(message);
                _checkoutParameters.onFailure(message);
              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith('https://') ||
                    request.url.startsWith('http://')) {
                  debugPrint('Allowing Navigation: URL ${request.url}');
                  return NavigationDecision.navigate;
                } else {
                  debugPrint('Preventing Navigation: URL ${request.url}');
                  return NavigationDecision.prevent;
                }
              },
            ),
          );
  }

  @override
  void dispose() {
    _checkoutWbController?.removeJavaScriptChannel('Toaster');
    _checkoutWbController = null;
    super.dispose();
  }

  Future<void> _enableLocalStorageAccess() async {
    if (_checkoutWbController != null) {
      await _checkoutWbController!.runJavaScriptReturningResult('''
        try {
          window.localStorage.setItem('test', 'value');
          window.localStorage.getItem('test');
        } catch (e) {
          console.error('Failed to access local storage:', e);
        }
      ''');
    }
  }
}
