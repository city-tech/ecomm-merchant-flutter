import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bundle_js/constants.dart';
import 'package:flutter_bundle_js/fail.dart';
import 'package:flutter_bundle_js/success.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// ─── Checkout WebView Page ─────────────────────────────────────────────────────
class CheckoutWebViewPage extends StatefulWidget {
  /// JS options string built in main.dart with cart data.
  /// payment.dart loads the bundle and calls getPay.initialize(checkoutOptions).
  final String checkoutOptions;

  const CheckoutWebViewPage({
    Key? key,
    required this.checkoutOptions,
  }) : super(key: key);

  @override
  _CheckoutWebViewPageState createState() => _CheckoutWebViewPageState();
}

class _CheckoutWebViewPageState extends State<CheckoutWebViewPage> {
  // Start as true → show loading until GetPay bundle is ready
  bool _isLoading = true;

  @override
  void dispose() {
    super.dispose();
  }

  // ─── HTML: empty #checkout div + load bundle ──────────────────────────────
  String _buildHtmlContent() {
    return '''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" />
    <title>GetPay Checkout</title>
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      html, body {
        width: 100%; height: 100%;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", sans-serif;
        background: #f5f5f5;
      }
      #checkout { width: 100%; min-height: 100%; }
    </style>
  </head>
  <body>
    <!-- GetPay form renders here (initialized in main.dart) -->
    <div id="checkout"></div>

    <script>
      // Load bundle
      const script = document.createElement('script');
      script.src = "${Constants.EXPO_PUBLIC_BUNDLE_URL}";
      script.async = true;
      document.head.appendChild(script);
    </script>
  </body>
</html>
''';
  }

  // ─── Handle payment URL redirects ──────────────────────────────────────────
  void _handlePaymentUrl(BuildContext context, String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    if (path.contains('success')) {
      final token = uri.queryParameters['token'];
      log('✓ Success: token=$token');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SuccessPage(token: token ?? '')),
      );
    } else if (path.contains('fail')) {
      final reason = uri.queryParameters['reason'];
      log('✓ Fail: reason=$reason');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => FailPage(reason: reason)),
      );
    }
  }

  bool _isPaymentUrl(String url) {
    final path = Uri.parse(url).path.toLowerCase();
    return path.contains('success') || path.contains('fail');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: _buildHtmlContent(),
              baseUrl: WebUri(Constants.EXPO_PUBLIC_WEBSITE_DOMAIN),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
              useWideViewPort: true,
              cacheEnabled: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            ),

            // ── JS Handlers ──────────────────────────────────────────────────
            onWebViewCreated: (controller) {
              // Clear stale payment data when checkout page opens
              controller.evaluateJavascript(source: '''
                try {
                  localStorage.removeItem('_DET');
                } catch(e) {
                  console.warn('Could not clear localStorage:', e);
                }
              ''');
              
              // Hide loading spinner when page loads
              controller.addJavaScriptHandler(
                handlerName: 'onCheckoutReady',
                callback: (args) {
                  if (mounted) setState(() => _isLoading = false);
                },
              );
            },

            onLoadStart: (controller, url) =>
                log('Page loading: $url'),

            // ── onLoadStop: hide loading + check for payment callback ────────
            onLoadStop: (controller, url) async {
              final loadedUrl = url.toString();
              if (mounted) setState(() => _isLoading = false);
              if (_isPaymentUrl(loadedUrl) && mounted) {
                _handlePaymentUrl(context, loadedUrl);
              }
            },

            // ── onReceivedError: catch iframe/sub-frame callbacks ───────────
            onReceivedError: (controller, request, error) {
              final errorUrl = request.url.toString();
              if (mounted) setState(() => _isLoading = false);

              if (error.description.contains('ERR_CONNECTION_REFUSED') ||
                  error.description.contains('net::ERR')) {
                if (_isPaymentUrl(errorUrl) && mounted) {
                  _handlePaymentUrl(context, errorUrl);
                }
              }
            },

            onReceivedHttpError: (controller, request, error) =>
                log('HTTP ${error.statusCode} → ${request.url}'),

            // ── shouldOverrideUrlLoading: intercept before load ─────────────
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';
              log('Navigation: $url');

              if (url.isEmpty) return NavigationActionPolicy.CANCEL;

              if (_isPaymentUrl(url)) {

                Future.microtask(() {
                  if (mounted) _handlePaymentUrl(context, url);
                });
                return NavigationActionPolicy.CANCEL;
              }

              final scheme = Uri.tryParse(url)?.scheme ?? '';
              if (scheme == 'http' || scheme == 'https') {
                return NavigationActionPolicy.ALLOW;
              }
              return NavigationActionPolicy.CANCEL;
            },
          ),

          // ── Loading overlay: shown until bundle is ready ──────────────────
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF5662FF)),
                    SizedBox(height: 16),
                    Text(
                      'Loading checkout...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
