import 'package:ecomm_merchant_demo/checkout_parameters.dart';
import 'package:ecomm_merchant_demo/failure_html.dart';
import 'package:ecomm_merchant_demo/success_html.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'checkout_html.dart';
import 'constants.dart';

class PaymentPage extends StatefulWidget {
  final CheckoutParameters _checkoutParameters;

  const PaymentPage(this._checkoutParameters, {super.key});

  @override
  _PaymentPage createState() => _PaymentPage(_checkoutParameters);
}

class _PaymentPage extends State<PaymentPage> {
  WebViewController? _paymentWbController;
  final CheckoutParameters _checkoutParameters;

  _PaymentPage(this._checkoutParameters);

  @override
  void initState() {
    debugPrint("Payment Page initState called");
    _initializePaymentWbController();
    _enableLocalStorageAccess();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GetPay CheckOut...')),
      body: Center(child: WebViewWidget(controller: _paymentWbController!)),
    );
  }

  void _initializePaymentWbController() {
    _paymentWbController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _enableLocalStorageAccess(),
          onWebResourceError: (WebResourceError error) {
            String message = 'WebView error: ${error.description}';
            debugPrint(message);
            if (error.url?.contains("localhost") == false) {
              _checkoutParameters.onFailure(message);
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message.toLowerCase() == "success") {
            _checkoutParameters.onSuccess(message.message);
          } else {
            _checkoutParameters.onFailure(message.message);
          }
        },
      )
      ..loadHtmlString(
        CheckoutHtml.paymentScript,
        baseUrl: Constants.EXPO_PUBLIC_WEBSITE_DOMAIN,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
                Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
                ''');
            if (error.url?.contains("localhost") == false) {
              _checkoutParameters.onFailure(
                error.errorCode.toString() + error.description,
              );
            } else if (error.url?.contains("success") == true) {
              _checkoutParameters.onSuccess("SUCCESS");
            } else if (error.url?.contains("failure") == true) {
              _checkoutParameters.onSuccess("FAILURE");
            }
          },
          onHttpError: (HttpResponseError error) {
            debugPrint(
              'Error occurred on page: ${error.response?.statusCode}',
            );
            if (error.request?.uri.toString().contains("localhost") == false) {
              _checkoutParameters.onFailure(
                'Error Code: ' + '${error.response?.statusCode}',
              );
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://') ||
                request.url.startsWith('http://')) {
              debugPrint('Allowing navigation to: ${request.url}');
              if (request.url.contains('success')) {
                _paymentWbController?.loadHtmlString(
                  _checkoutParameters.customSuccessHtml ?? SuccessHtml.content,
                  baseUrl: request.url,
                );
                if (_checkoutParameters.customSuccessHtml
                        ?.contains("localhost") ==
                    true) {
                  _checkoutParameters.onSuccess("SUCCESS");
                }
              } else {
                _paymentWbController?.loadHtmlString(
                  _checkoutParameters.customFailureHtml ?? FailureHtml.content,
                  baseUrl: request.url,
                );
                if (_checkoutParameters.customFailureHtml
                        ?.contains("localhost") ==
                    true) {
                  _checkoutParameters.onSuccess("FAILURE");
                }
              }
              return NavigationDecision.prevent;
            } else {
              debugPrint('Blocking navigation to: ${request.url}');
              return NavigationDecision.prevent;
            }
          },
        ),
      );
  }

  Future<void> _enableLocalStorageAccess() async {
    if (_paymentWbController != null) {
      await _paymentWbController!.runJavaScriptReturningResult('''
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
  void dispose() {
    _paymentWbController?.removeJavaScriptChannel('Toaster');
    _paymentWbController = null;
    super.dispose();
    //
  }
}
