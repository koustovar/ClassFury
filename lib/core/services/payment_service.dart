import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  late Razorpay _razorpay;
  bool _initialized = false;
  bool _listenersRegistered = false;

  // Callbacks
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function(ExternalWalletResponse)? onExternalWallet;

  void initialize({
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
    Function(ExternalWalletResponse)? onWallet,
  }) {
    if (_initialized) return;

    _razorpay = Razorpay();
    _initialized = true;

    setCallbacks(
      onSuccess: onSuccess,
      onError: onError,
      onWallet: onWallet,
    );
  }

  void setCallbacks({
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onError,
    Function(ExternalWalletResponse)? onWallet,
  }) {
    onPaymentSuccess = onSuccess;
    onPaymentError = onError;
    onExternalWallet = onWallet;

    if (!_initialized) {
      _razorpay = Razorpay();
      _initialized = true;
    }

    if (!_listenersRegistered) {
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      _listenersRegistered = true;
    }
  }

  void openCheckout({
    required String key,
    required double amount, // in rupees
    required String name,
    required String description,
    String? orderId,
    required String prefillEmail,
    required String prefillContact,
  }) {
    if (!_initialized) {
      initialize();
    }

    final options = {
      'key': key,
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paisa
      'name': name,
      'description': description,
      'prefill': {
        'contact': prefillContact,
        'email': prefillEmail,
      },
      'theme': {
        'color': '#3399cc',
      },
    };

    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    onExternalWallet?.call(response);
  }

  void dispose() {
    _razorpay.clear();
  }
}
