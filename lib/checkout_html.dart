import 'package:flutter/cupertino.dart';

import 'constants.dart';

class CheckoutHtml {
  static String checkoutScript = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"/>
    <title>Getpay Merchant Demo</title>
    <script defer="defer" src="https://minio.finpos.global/getpay-cdn/webcheckout/live/v2/bundle.js"></script>
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
    const options = {
        userInfo: {
            name: "",
            email: "",
            state: "",
            country: "",
            zipcode: "",
            city: "",
            address: ""
        },
        papInfo: "${Constants.EXPO_PUBLIC_PAP_INFO}",
        oprKey: "${Constants.EXPO_PUBLIC_OPR_KEY}",
        insKey: "",
        websiteDomain: "${Constants.EXPO_PUBLIC_WEBSITE_DOMAIN}",
        price: 1000.00,
        businessName: "${Constants.EXPO_PUBLIC_BUSINESS_NAME}",
        imageUrl: "${Constants.EXPO_PUBLIC_LOGO_URL}",
        clientRequestId: "123789",
        baseUrl: "https://getpay-qa.finpos.global/ecom-gateway/v1/secure-merchant/transactions",
        currency: "NPR",
        callbackUrl: {
            successUrl: "${Constants.EXPO_PUBLIC_SUCCESS_URL}",
            failUrl: "${Constants.EXPO_PUBLIC_FAIL_URL}"
        },
        themeColor: "#5662FF",
        orderInformationUI: `
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
            </div>`,
        onSuccess: (response) => {
            Toaster.postMessage("success");  // No need for window.onload here
        },
        // Handle error response
        onError: (error) => {
            Toaster.postMessage("error");  // No need for window.onload here
        },
    };

    document.getElementById('checkout-btn').onclick = function (e) {
        if (window.Toaster && typeof window.Toaster.postMessage === 'function') {
            window.Toaster.postMessage("success");
        } else {
            console.log("Toaster channel is not available.");
        }

        const getPay = new GetPay(options);
        getPay.initialize();
    };
</script>
</body>
</html>
  ''';

  static String paymentScript = '''
      <html lang="en">
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"/>
          <title>Getpay Merchant Demo</title>
          <script defer="defer" src="https://minio.finpos.global/getpay-cdn/webcheckout/live/v2/bundle.js"></script>
        </head>
        <body>
          <div id="checkout"></div>
        </body>
      </html>
      ''';

  String checkoutWithParameters(
    String merchantName,
    String papInfo,
    String secretKey,
    String institutionKey,
    String websiteDomain,
    double amount,
    String businessName,
    String imageUrl,
    String bank,
    String clientRequestId,
    String currency,
  ) {
    String baseUrl = _mapUrlWithBankCode(bank);
    String htmlString = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no"/>
    <title>$merchantName</title>
    <script defer="defer" src="https://minio.finpos.global/getpay-cdn/webcheckout/live/v2/bundle.js"></script>
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
    const options = {
        userInfo: {
            name: "",
            email: "",
            state: "",
            country: "",
            zipcode: "",
            city: "",
            address: ""
        },
        papInfo: "$papInfo",
        oprKey: "$secretKey",
        insKey: "$institutionKey",
        websiteDomain: "$websiteDomain",
        price: $amount,
        businessName: "$businessName",
        imageUrl: "$imageUrl",
        clientRequestId: "$clientRequestId",
        baseUrl: "$baseUrl",
        currency: "$currency",
        callbackUrl: {
            successUrl: "${Constants.EXPO_PUBLIC_SUCCESS_URL}",
            failUrl: "${Constants.EXPO_PUBLIC_FAIL_URL}"
        },
        themeColor: "#5662FF",
        orderInformationUI: `
          <div style='display: flex; align-items: center; margin-bottom: 10px;'>
            <p>Payment for $currency $amount</p>
          </div>`,
        onSuccess: (response) => {
            Toaster.postMessage("success");  
        },
        onError: (error) => {
            Toaster.postMessage("error");
        },
    };

    document.getElementById('checkout-btn').onclick = function (e) {
        if (window.Toaster && typeof window.Toaster.postMessage === 'function') {
            window.Toaster.postMessage("success");
        } else {
            console.log("Toaster channel is not available.");
        }

        const getPay = new GetPay(options);
        getPay.initialize();
    };
</script>
</body>
</html>
    ''';
    debugPrint('GENERATED HTML STRING $htmlString');
    return htmlString;
  }

  String _mapUrlWithBankCode(String bank) {
    switch (bank) {
      case "QA":
        return "https://getpay-qa.finpos.global/ecom-gateway/v1/secure-merchant/transactions";
      case "UAT":
        return "https://getpay-uat.finpos.global/ecom-gateway/v1/secure-merchant/transactions";
      default:
        return "https://getpay-dev.finpos.global/ecom-gateway/v1/secure-merchant/transactions";
    }
  }
}
