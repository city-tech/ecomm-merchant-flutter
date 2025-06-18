import 'dart:developer';

import 'package:ecomm_merchant_demo/checkout_html.dart';
import 'package:ecomm_merchant_demo/checkout_parameters.dart';
import 'package:ecomm_merchant_demo/failure_html.dart';
import 'package:ecomm_merchant_demo/success_html.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'constants.dart';
export 'package:ecomm_merchant_demo/checkout_page.dart';

class CheckoutPage extends StatefulWidget {
  final CheckoutParameters _checkoutParameters;

  const CheckoutPage(this._checkoutParameters, {super.key});

  @override
  _CheckoutPage createState() => _CheckoutPage();
}

class _CheckoutPage extends State<CheckoutPage> {
  WebViewController? _checkoutWbController;

  @override
  void initState() {
    debugPrint("Checkout Page initState called");
    _initializeCheckoutWbController();
    super.initState();
  }

  bool isPaymentInitiated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checking Out...')),
      body: _checkoutWbController == null
          ? Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ))
          : Center(child: WebViewWidget(controller: _checkoutWbController!)),
    );
  }

  void _initializeCheckoutWbController() {
    final controller = WebViewController(
      onPermissionRequest: (request) {
        request.platform.grant();
      },
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message.toLowerCase() == "success") {
            widget._checkoutParameters.onSuccess(message.message);
          } else {
            widget._checkoutParameters.onFailure(message.message);
          }
        },
      )
      ..loadHtmlString(
        CheckoutHtml().checkoutWithParameters(
          widget._checkoutParameters.merchantName,
          widget._checkoutParameters.papInfo,
          widget._checkoutParameters.secretKey,
          widget._checkoutParameters.institutionKey != null
              ? widget._checkoutParameters.institutionKey!
              : '',
          widget._checkoutParameters.websiteDomain != null
              ? widget._checkoutParameters.websiteDomain!
              : Constants.EXPO_PUBLIC_WEBSITE_DOMAIN,
          widget._checkoutParameters.amount,
          widget._checkoutParameters.businessName,
          widget._checkoutParameters.logoUrl,
          widget._checkoutParameters.bank,
          widget._checkoutParameters.requestNumber,
          widget._checkoutParameters.currency,
        ),
        // CheckoutHtml.checkoutScript,
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
            await _enableLocalStorageAccess();
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            log('''
                Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
                ''');
            log(error.errorCode.toString());
            if (error.url?.contains("localhost") == false) {
              widget._checkoutParameters.onFailure(
                error.errorCode.toString() + error.description,
              );
            } else if (error.url?.contains("success") == true) {
              widget._checkoutParameters.onSuccess("SUCCESS");
            } else if (error.url?.contains("failure") == true) {
              widget._checkoutParameters.onFailure("FAILURE");
            }
          },
          onHttpError: (HttpResponseError error) {
            debugPrint(
              'Error occurred on page: ${error.response?.statusCode}',
            );
            if (error.request?.uri.toString().contains("localhost") == false) {
              widget._checkoutParameters.onFailure(
                'Error Code: ' + '${error.response?.statusCode}',
              );
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith('https://') ||
                request.url.startsWith('http://')) {
              debugPrint('Payment page  navigation to:  ${request.url}');
              if (request.url.contains('success') && !isPaymentInitiated) {
                isPaymentInitiated = true;
                await _checkoutWbController?.loadHtmlString(
                  widget._checkoutParameters.customSuccessHtml ??
                      SuccessHtml.content,
                  baseUrl: request.url,
                );
                if (widget._checkoutParameters.customSuccessHtml
                        ?.contains("localhost") ==
                    true) {
                  widget._checkoutParameters.onSuccess("SUCCESS");
                }

                return NavigationDecision.prevent;
              } else if (request.url.contains('fail') && !isPaymentInitiated) {
                isPaymentInitiated = true;

                if (widget._checkoutParameters.customFailureHtml
                        ?.contains("localhost") ==
                    true) {
                  widget._checkoutParameters.onFailure("FAILURE");
                }

                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            } else {
              debugPrint('Blocking navigation to: ${request.url}');
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..setOnConsoleMessage((consoleMessage) =>
          debugPrint(" console msg${consoleMessage.message}"));

    setState(() {
      _checkoutWbController = controller;
    });
  }

  @override
  void dispose() {
    _checkoutWbController?.removeJavaScriptChannel('Toaster');
    _checkoutWbController = null;
    super.dispose();
  }

  Future<void> _enableLocalStorageAccess() async {
    if (_checkoutWbController != null) {
      await _checkoutWbController!.runJavaScript('''
  try {
    window.localStorage.setItem('test', 'value');
    const value = window.localStorage.getItem('test');
    console.log("LocalStorage set/get success:", value);
  } catch (e) {
    console.error('LocalStorage error:', e);
  }
''');
    }
  }
}
