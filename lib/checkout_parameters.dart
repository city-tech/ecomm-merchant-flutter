export 'package:ecomm_merchant_demo/checkout_parameters.dart';

class CheckoutParameters {
  late String _merchantName;
  late String _papInfo;
  late String _secretKey;
  String? _institutionKey;
  String? _websiteDomain;
  late double _amount;
  late String _businessName;
  late String _logoUrl;
  late String _bank;
  late String _requestNumber;
  late String _currency;
  late Function(String message) _onSuccess;
  late Function(String errorMessage) _onFailure;

  String get merchantName => _merchantName;

  set merchantName(String value) {
    _merchantName = value;
  }

  String get papInfo => _papInfo;

  Function(String errorMessage) get onFailure => _onFailure;

  set onFailure(Function(String errorMessage) value) {
    _onFailure = value;
  }

  Function(String message) get onSuccess => _onSuccess;

  set onSuccess(Function(String message) value) {
    _onSuccess = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
  }

  String get requestNumber => _requestNumber;

  set requestNumber(String value) {
    _requestNumber = value;
  }

  String get bank => _bank;

  set bank(String value) {
    _bank = value;
  }

  String get logoUrl => _logoUrl;

  set logoUrl(String value) {
    _logoUrl = value;
  }

  String get businessName => _businessName;

  set businessName(String value) {
    _businessName = value;
  }

  double get amount => _amount;

  set amount(double value) {
    _amount = value;
  }

  String? get websiteDomain => _websiteDomain;

  set websiteDomain(String? value) {
    _websiteDomain = value;
  }

  String? get institutionKey => _institutionKey;

  set institutionKey(String? value) {
    _institutionKey = value;
  }

  String get secretKey => _secretKey;

  set secretKey(String value) {
    _secretKey = value;
  }

  set papInfo(String value) {
    _papInfo = value;
  }

  String? customSuccessHtml;
  String? customFailureHtml;

  //toString
  @override
  String toString() {
    return "CheckoutParameters{" "merchantName='" +
        _merchantName +
        '\'' +
        ", papInfo='" +
        _papInfo +
        '\'' +
        ", secretKey='" +
        _secretKey +
        '\'' +
        '}';
  }
}
