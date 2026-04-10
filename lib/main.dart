import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bundle_js/payment.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'constants.dart' as Constants;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter WebView Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CartPage(),
    );
  }
}

// ─── Cart Page ────────────────────────────────────────────────────────────────
class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int counter1 = 1;
  int _counter2 = 1;
  bool _bundleLoaded = false;
  bool _isCheckingOut = false;
  InAppWebViewController? _bgController;

  int get _grandTotal => counter1 * 600 + _counter2 * 400;

  int calculateTotalEachCup({required int count, required int price}) => count * price;
  int calculateTotalEachSpeaker({required int count, required int price}) => count * price;

  // ─── Background HTML: loads bundle only on startup ────────────────────────
  String get _preloadHtml => '''
<!DOCTYPE html><html lang="en">
<head><meta charset="UTF-8"/></head>
<body>
  <div id="checkout"></div>
  <script>
    const script = document.createElement('script');
    script.src = "${Constants.Constants.EXPO_PUBLIC_BUNDLE_URL}";
    script.async = true;
    script.onload = function() {
      if (window.flutter_inappwebview)
        window.flutter_inappwebview.callHandler('onBundleLoaded');
    };
    script.onerror = function() {
      console.warn('Bundle load failed');
    };
    document.head.appendChild(script);
  </script>
</body></html>
''';

  // ─── Build checkoutOptions with cart data ─────────────────────────────────
  // onSuccess fires after GetPay's internal validation APIs complete
  // → form is rendered in #checkout → navigate to payment.dart
  String _buildCheckoutOptions() {
    return '''
{
  userInfo: {
    name: "John Doe",
    email: "john@gmail.com",
    state: "Bagmati",
    country: "NPL",
    zipcode: "44600",
    city: "Kathmandu",
    address: "Chabahil",
    phone: "+977-9800000000"
  },
  papInfo: "${Constants.Constants.EXPO_PUBLIC_PAP_INFO}",
  oprKey: "${Constants.Constants.EXPO_PUBLIC_OPR_KEY}",
  insKey: "${Constants.Constants.EXPO_PUBLIC_INS_KEY}",
  websiteDomain: "${Constants.Constants.EXPO_PUBLIC_WEBSITE_DOMAIN}",
  baseUrl: "${Constants.Constants.EXPO_PUBLIC_BASE_URL}",
  price: "$_grandTotal",
  currency: "NPR",
  businessName: "${Constants.Constants.EXPO_PUBLIC_BUSINESS_NAME}",
  imageUrl: "${Constants.Constants.EXPO_PUBLIC_LOGO_URL}",
  prefill: { name: true, email: true, state: true, city: true, address: true, zipcode: true, country: true, phone: true },
  disableFields: { address: false, state: false },
  callbackUrl: {
    successUrl: "${Constants.Constants.EXPO_PUBLIC_SUCCESS_URL}",
    failUrl: "${Constants.Constants.EXPO_PUBLIC_FAIL_URL}"
  },
  themeColor: "#5662FF",
  termsText: "I agree to the Terms & Conditions and Privacy Policy",
  orderInformationUI: \`
    <div style='padding: 16px; background: #f9f9f9; border-radius: 8px; margin-bottom: 16px;'>
      <h3 style='margin-bottom: 12px; font-size: 16px; font-weight: 600;'>Order Summary</h3>
      <div style='display: flex; align-items: center; margin-bottom: 12px; padding-bottom: 12px; border-bottom: 1px solid #eee;'>
        <img style='width: 50px; height: 50px; margin-right: 12px; border-radius: 4px; object-fit: cover;'
          src='https://media.istockphoto.com/id/821282266/photo/white-mug-isolated.jpg?s=2048x2048&w=is&k=20&c=aMUoxLBq_4VOE5HbYpWebboQNerQzoH4ASAiFjk0R3g=' alt='Cup'>
        <div style='flex: 1;'>
          <p style='margin: 0; font-weight: 500;'>Cups (x$counter1)</p>
          <p style='margin: 0; color: #999; font-size: 14px;'>Rs 600 each</p>
        </div>
        <p style='margin: 0; font-weight: 600;'>Rs ${counter1 * 600}</p>
      </div>
      <div style='display: flex; align-items: center; margin-bottom: 12px; padding-bottom: 12px; border-bottom: 1px solid #eee;'>
        <img style='width: 50px; height: 50px; margin-right: 12px; border-radius: 4px; object-fit: cover;'
          src='https://www.artis.in/cdn/shop/products/1_f5b3377c-c870-420f-bc6a-5cd4b3a5a7c7.jpg?v=1653639993' alt='Speaker'>
        <div style='flex: 1;'>
          <p style='margin: 0; font-weight: 500;'>Speaker (x$_counter2)</p>
          <p style='margin: 0; color: #999; font-size: 14px;'>Rs 400 each</p>
        </div>
        <p style='margin: 0; font-weight: 600;'>Rs ${_counter2 * 400}</p>
      </div>
      <div style='display: flex; align-items: center; padding-top: 12px;'>
        <div style='flex: 1;'><p style='margin: 0; font-weight: 600; font-size: 16px;'>Grand Total</p></div>
        <p style='margin: 0; font-weight: 700; font-size: 18px; color: #5662FF;'>Rs $_grandTotal</p>
      </div>
    </div>\`,
  onSuccess: function(response) {
    // Internal validation APIs done → form rendered → navigate to payment.dart
    if (window.flutter_inappwebview)
      window.flutter_inappwebview.callHandler('onPaymentReady');
  },
  onError: function(error) {
    if (window.flutter_inappwebview)
      window.flutter_inappwebview.callHandler('onPaymentError', JSON.stringify(error));
  },
  onClose: function() {
    console.log('GetPay onClose');
  }
}
''';
  }

  // ─── Called when checkout button clicked ─────────────────────────────────
  // Bundle is already loaded → just call getPay.initialize(options)
  Future<void> _onCheckoutPressed(BuildContext context) async {
    if (_bgController == null) {
      log('✗ Background WebView not ready');
      return;
    }
    if (!_bundleLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading payment gateway, please try again...')),
      );
      return;
    }

    setState(() => _isCheckingOut = true);

    final options = _buildCheckoutOptions();
    await _bgController!.evaluateJavascript(source: '''
      try {
        const options = $options;
        const getPay = new GetPay(options);
        getPay.initialize();
      } catch(e) {
        if (window.flutter_inappwebview)
          window.flutter_inappwebview.callHandler('onPaymentError', e.message);
      }
    ''');
  }

  Widget _itemCounter({
    required int count,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: 140,
      height: 100,
      child: Row(
        children: [
          Card(child: IconButton(onPressed: onAdd, icon: Icon(Icons.add))),
          Text(count.toString()),
          Card(child: IconButton(onPressed: onRemove, icon: Icon(Icons.remove))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Cart')),
      body: Column(
        children: [
          // ── Hidden WebView: loads bundle on startup ────────────────────────
          Offstage(
            offstage: true,
            child: SizedBox(
              height: 1, width: 1,
              child: InAppWebView(
                initialData: InAppWebViewInitialData(
                  data: _preloadHtml,
                  baseUrl: WebUri(Constants.Constants.EXPO_PUBLIC_WEBSITE_DOMAIN),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  cacheEnabled: true,
                ),
                onWebViewCreated: (controller) {
                  _bgController = controller;

                  // Bundle loaded → ready for checkout
                  controller.addJavaScriptHandler(
                    handlerName: 'onBundleLoaded',
                    callback: (args) {

                      setState(() => _bundleLoaded = true);
                    },
                  );

                  // onSuccess in options → navigate to payment.dart
                  controller.addJavaScriptHandler(
                    handlerName: 'onPaymentReady',
                    callback: (args) {

                      setState(() => _isCheckingOut = false);
                      final options = _buildCheckoutOptions();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutWebViewPage(checkoutOptions: options),
                        ),
                      );
                    },
                  );

                  // onError in options
                  controller.addJavaScriptHandler(
                    handlerName: 'onPaymentError',
                    callback: (args) {

                      setState(() => _isCheckingOut = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${args.isNotEmpty ? args[0] : "Unknown"}')),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // ── Cart UI ────────────────────────────────────────────────────────
          Container(
            height: 60.0,
            decoration: const BoxDecoration(color: Color.fromARGB(255, 241, 235, 179)),
            child: const Center(child: Text('TEST Online Store', style: TextStyle(fontSize: 18))),
          ),
          const Divider(color: Colors.grey, thickness: 1),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Cart Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
            ),
          ),
          ListTile(
            leading: SizedBox(height: 60, width: 60, child: Image.asset('assets/cup.png')),
            title: Text('Cup Set', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Rs 600'), Divider(),
              Text("Total: ${calculateTotalEachCup(count: counter1, price: 600)}")
            ]),
            trailing: _itemCounter(
              count: counter1,
              onAdd: () => setState(() => counter1 += 1),
              onRemove: () => setState(() { if (counter1 > 1) counter1 -= 1; }),
            ),
          ),
          ListTile(
            leading: SizedBox(height: 60, width: 60, child: Image.asset('assets/speaker.png')),
            title: Text('Speaker', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Rs 400'), Divider(),
              Text("Total: ${calculateTotalEachSpeaker(count: _counter2, price: 400)}")
            ]),
            trailing: _itemCounter(
              count: _counter2,
              onAdd: () => setState(() => _counter2 += 1),
              onRemove: () => setState(() { if (_counter2 > 1) _counter2 -= 1; }),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Rs $_grandTotal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5662FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isCheckingOut ? null : () => _onCheckoutPressed(context),
                child: _isCheckingOut
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Checkout', style: TextStyle(fontSize: 18, color: Colors.white)),
                          if (_bundleLoaded) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.bolt, color: Colors.white, size: 18),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
