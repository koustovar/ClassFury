import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PurchaseService {
  // Load API key from environment variable
  static String get _apiKey => dotenv.env['REVENUE_CAT_API_KEY'] ?? '';

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_apiKey.isEmpty) {
      print(
        'RevenueCat API key not configured. '
        'Skipping purchase service initialization. '
        'Add REVENUE_CAT_API_KEY to your .env file to enable.',
      );
      return;
    }
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      final configuration = PurchasesConfiguration(_apiKey);
      await Purchases.configure(configuration);
      _initialized = true;
    } catch (e) {
      print('Failed to initialize RevenueCat: $e');
      // Don't rethrow — allow the app to start without purchases
    }
  }

  Future<bool> isPremium() async {
    if (!_initialized) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all['premium']?.isActive ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<List<Package>> getOfferings() async {
    if (!_initialized) return [];
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } on PlatformException catch (_) {
      // Handle error
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    if (!_initialized) return false;
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      return purchaseResult
              .customerInfo.entitlements.all['premium']?.isActive ??
          false;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        // Handle error
      }
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_initialized) return;
    try {
      await Purchases.restorePurchases();
    } on PlatformException catch (_) {
      // Handle error
    }
  }
}
