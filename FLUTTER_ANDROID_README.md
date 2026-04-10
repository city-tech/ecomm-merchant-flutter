# ecomm-merchant-flutter

A Flutter e-commerce merchant demo app that integrates the **GetPay** payment gateway via a JavaScript bundle loaded inside an `InAppWebView`. The app shows a cart with two products, lets the user adjust quantities, and processes checkout through the GetPay SDK — navigating to a native success or failure screen based on the payment callback URL.

---

## Table of Contents

- [Project Structure](#project-structure)
- [App Flow](#app-flow)
- [Dependencies](#dependencies)
- [Android Build Requirements](#android-build-requirements)
- [Constants Configuration](#constants-configuration)
- [Key Implementation Details](#key-implementation-details)
  - [main.dart — Cart Page](#maindart--cart-page)
  - [payment.dart — Checkout WebView](#paymentdart--checkout-webview)
  - [success.dart — Payment Success Page](#successdart--payment-success-page)
  - [fail.dart — Payment Failure Page](#faildart--payment-failure-page)
  - [constants.dart — Configuration](#constantsdart--configuration)
- [URL Interception & Redirect Logic](#url-interception--redirect-logic)
- [Known Issues & Fixes Applied](#known-issues--fixes-applied)
- [Running the App](#running-the-app)

---

## Project Structure

```
lib/
├── main.dart        # CartPage + hidden background WebView (bundle preload + GetPay init)
├── payment.dart     # CheckoutWebViewPage (renders GetPay form, intercepts callback URLs)
├── success.dart     # SuccessPage (decodes Base64 token, shows transaction details)
├── fail.dart        # FailPage (shows failure reason and retry options)
└── constants.dart   # All environment / configuration constants

assets/
├── cup.png
└── speaker.png
```

---

## App Flow

```
App Launch
    │
    ▼
CartPage (main.dart)
    │
    ├── Hidden InAppWebView loads in background
    │       └── Fetches bundle JS from EXPO_PUBLIC_BUNDLE_URL
    │               └── onBundleLoaded() → _bundleLoaded = true
    │
    ├── User adjusts cart (Cup × N  +  Speaker × M)
    │
    ├── User taps "Checkout"
    │       └── _onCheckoutPressed()
    │               ├── Calls getPay.initialize(checkoutOptions) on the background WebView
    │               └── GetPay runs internal validation APIs
    │
    └── onSuccess fired by GetPay JS SDK
            └── onPaymentReady handler → Navigator.push → CheckoutWebViewPage (payment.dart)

CheckoutWebViewPage (payment.dart)
    │
    ├── Loads same bundle again in a fresh full-screen InAppWebView
    │       └── <div id="checkout"> — GetPay form renders here
    │
    ├── Loading overlay shown until onLoadStop fires
    │
    ├── User fills in payment details (card number, OTP, etc.)
    │
    └── GetPay backend redirects WebView to one of:
            ├── http://localhost:3000/success?token=<Base64>
            │       └── shouldOverrideUrlLoading / onReceivedError / onLoadStop
            │               └── _handlePaymentUrl() → Navigator.pushReplacement → SuccessPage
            │
            └── http://localhost:3000/fail?reason=<string>
                    └── → Navigator.pushReplacement → FailPage

SuccessPage (success.dart)
    │
    ├── Decodes Base64 token → JSON
    ├── Displays transaction details (id, oprSecret, etc.)
    └── "Back to Cart" → popUntil(first route)

FailPage (fail.dart)
    ├── Shows failure reason
    ├── "Try Again" → pop back
    └── "Back to Cart" → popUntil(first route)
```

---

## Dependencies

### Flutter / Dart (pubspec.yaml)

| Package | Version | Purpose |
|---|---|---|
| `flutter_inappwebview` | `^6.0.0` | Embeds a full Chromium WebView; handles JS handlers, URL interception, `shouldOverrideUrlLoading` |
| `permission_handler` | `^12.0.0` | Requests Android runtime permissions (INTERNET, etc.) |
| `webview_flutter_plus` | `^0.4.7` | (Unused in current active code, kept as fallback) |
| `cupertino_icons` | `^1.0.6` | iOS-style icons |
| `url_launcher` | `^6.1.7` | (dev dependency — may be used for external link support) |

Add/verify in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  flutter_inappwebview: ^6.0.0
  permission_handler: ^12.0.0
  webview_flutter_plus: ^0.4.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  url_launcher: ^6.1.7
```

Run:

```bash
flutter pub get
```

---

## Android Build Requirements

The following versions are **required** to build successfully:

| Component | Required Version | Where to set |
|---|---|---|
| **Gradle Wrapper** | `8.11.1` | `android/gradle/wrapper/gradle-wrapper.properties` → `distributionUrl` |
| **Android Gradle Plugin (AGP)** | `8.9.1` | `android/settings.gradle` → `com.android.application` version |
| **Kotlin Gradle Plugin (KGP)** | `2.1.0` | `android/settings.gradle` → `org.jetbrains.kotlin.android` version |
| **Java / Kotlin JVM target** | `17` | `android/app/build.gradle` → `compileOptions` / `kotlinOptions` |
| **Min SDK** | Flutter default (≥21) | `android/app/build.gradle` → `minSdkVersion` |

### android/gradle/wrapper/gradle-wrapper.properties

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.11.1-all.zip
```

### android/settings.gradle

```groovy
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.9.1" apply false
    id "org.jetbrains.kotlin.android" version "2.1.0" apply false
}
```

### android/app/build.gradle

```groovy
compileOptions {
    sourceCompatibility JavaVersion.VERSION_17
    targetCompatibility JavaVersion.VERSION_17
}
kotlinOptions {
    jvmTarget = '17'
}
```

### Android Manifest Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

For physical device USB install — ensure **USB Debugging** and **Install via USB** are enabled in developer options on the device.

---

## Constants Configuration

All API keys and URLs live in `lib/constants.dart`:

```dart
class Constants {
  static const String EXPO_PUBLIC_BUSINESS_NAME  = "OneStop Shopping - Kathmandu";
  static const String EXPO_PUBLIC_PAP_INFO        = "<base64-encoded-pap-info>";
  static const String EXPO_PUBLIC_OPR_KEY         = "<your-opr-key-uuid>";
  static const String EXPO_PUBLIC_INS_KEY         = "000";

  // Domain used as the base URL of the WebView (must match callbackUrl host)
  static const String EXPO_PUBLIC_WEBSITE_DOMAIN  = "http://localhost:3000";

  // GetPay JS bundle CDN
  static const String EXPO_PUBLIC_BUNDLE_URL      =
      "https://minio.finpos.global/getpay-cdn/webcheckout/v5/bundle.js";

  static const String EXPO_PUBLIC_LOGO_URL        = "<merchant-logo-url>";

  // Callback URLs — GetPay backend will redirect the WebView to these
  static const String EXPO_PUBLIC_SUCCESS_URL     = "http://localhost:3000/success";
  static const String EXPO_PUBLIC_FAIL_URL        = "http://localhost:3000/fail";

  // GetPay backend transaction endpoint
  static const String EXPO_PUBLIC_BASE_URL        =
      "https://getpay-qa.finpos.global/ecom-gateway/v1/secure-merchant/transactions";
}
```

> **Note:** `localhost:3000` is intentional — it acts as a sentinel URL that the Android device **cannot** reach. The WebView will fire `onReceivedError` (ERR_CONNECTION_REFUSED) or `shouldOverrideUrlLoading` with this URL, which the Flutter code intercepts to trigger navigation to `SuccessPage` or `FailPage` **without** needing a real server running.

---

## Key Implementation Details

### main.dart — Cart Page

| Feature | Implementation |
|---|---|
| **Bundle Preload** | A 1×1 `Offstage` `InAppWebView` loads the GetPay bundle JS on app start so checkout is instant |
| **Bundle Ready Indicator** | A ⚡ icon appears on the Checkout button once `onBundleLoaded` JS handler fires |
| **Checkout Options** | `_buildCheckoutOptions()` builds a JS object literal with cart totals, user info, keys, and callback URLs |
| **GetPay Initialization** | `_onCheckoutPressed()` calls `getPay.initialize(options)` via `evaluateJavascript()` on the background WebView |
| **Navigation to Payment** | `onSuccess` in checkoutOptions calls `flutter_inappwebview.callHandler('onPaymentReady')` → Flutter navigates to `CheckoutWebViewPage` |
| **Loading State** | Button shows `CircularProgressIndicator` while `_isCheckingOut = true` |

### payment.dart — Checkout WebView

| Feature | Implementation |
|---|---|
| **Bundle Reload** | Loads the same bundle URL in a fresh full-screen WebView so GetPay can re-render the form in `<div id="checkout">` |
| **localStorage Cleanup** | On `onWebViewCreated`, removes `_DET` key from `localStorage` to prevent stale payment state |
| **Loading Overlay** | White overlay with spinner is shown until `onLoadStop` fires (`_isLoading = true → false`) |
| **URL Interception (primary)** | `shouldOverrideUrlLoading` checks if URL path contains `success` or `fail` → calls `_handlePaymentUrl()` and returns `CANCEL` so the WebView does not navigate |
| **URL Interception (fallback)** | `onReceivedError` also checks for `ERR_CONNECTION_REFUSED` on a payment URL (catches iframe/sub-frame redirects) |
| **URL Interception (tertiary)** | `onLoadStop` re-checks the loaded URL as a final safety net |
| **Token / Reason Extraction** | `_handlePaymentUrl()` parses `Uri.queryParameters['token']` (success) or `['reason']` (fail) |

### success.dart — Payment Success Page

| Feature | Implementation |
|---|---|
| **Token Decode** | Base64-decodes the URL `token` parameter → JSON → `Map<String, dynamic>` |
| **Transaction Details** | Renders all key-value pairs from the decoded JSON in a `Card` |
| **Error Fallback** | Shows raw token in a red card if Base64/JSON decode fails |
| **Navigation** | "Back to Cart" → `popUntil(route.isFirst)` |

### fail.dart — Payment Failure Page

| Feature | Implementation |
|---|---|
| **Reason Display** | Shows `reason` query param or a default message |
| **Bullet Points** | Lists common failure causes |
| **Navigation** | "Try Again" → `pop()`, "Back to Cart" → `popUntil(first)` |

### constants.dart — Configuration

Central place for all API keys, URLs, and CDN paths. No hardcoded values in screen files.

---

## URL Interception & Redirect Logic

The GetPay backend sends a form POST (from `cardinalcommerce.com`) which redirects the WebView to:

```
http://localhost:3000/success?token=<Base64JWT>
http://localhost:3000/fail?reason=<string>
```

Because `localhost:3000` is unreachable on a real device, the sequence is:

```
1. shouldOverrideUrlLoading fires with the success/fail URL
       └── Flutter intercepts → CANCEL navigation → pushReplacement to SuccessPage/FailPage ✅

   (If shouldOverrideUrlLoading fires AFTER the load starts:)

2. onReceivedError fires with ERR_CONNECTION_REFUSED on the success/fail URL
       └── Flutter intercepts → pushReplacement ✅

3. onLoadStop fires with the success/fail URL (even on error pages)
       └── Flutter intercepts as final fallback ✅
```

All three handlers call `_isPaymentUrl(url)` which checks:

```dart
bool _isPaymentUrl(String url) {
  final path = Uri.parse(url).path.toLowerCase();
  return path.contains('success') || path.contains('fail');
}
```

---

## Known Issues & Fixes Applied

| Issue | Fix |
|---|---|
| Kotlin version `1.8.0` too low | Updated `settings.gradle` → KGP `2.1.0` |
| AGP `8.1.1` too low for `androidx.browser:1.9.0` | Updated `settings.gradle` → AGP `8.9.1` |
| Gradle `8.7` too low for AGP `8.9.1` | Updated `gradle-wrapper.properties` → Gradle `8.11.1` |
| `permission_handler_android` v10 `Registrar` compile error | Upgrade `permission_handler` to `^12.0.0` in `pubspec.yaml` |
| `ERR_CONNECTION_REFUSED` preventing redirect | Intercept URL in all three WebView callbacks (see above) |
| Stale `_DET` localStorage causing duplicate payment triggers | `localStorage.removeItem('_DET')` in `payment.dart` `onWebViewCreated` |
| GetPay `onSuccess` firing before form is filled | `onSuccess` in GetPay options = internal API validation complete, not user submission — this is correct behaviour; it signals that the form is ready to display |
| `page_load_metrics` first_paint chromium warnings | Cosmetic Chromium internal logs, not app errors — can be ignored |

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on connected Android device (ensure USB Debugging is ON)
flutter run

# Build APK
flutter build apk --debug

# If you hit Gradle/AGP validation errors, skip checks temporarily:
flutter run --android-skip-build-dependency-validation
```

> **Physical Device Install:** If `INSTALL_FAILED_USER_RESTRICTED` appears, go to **Settings → Developer Options → Install via USB** and enable it, then confirm the install dialog on the device.
