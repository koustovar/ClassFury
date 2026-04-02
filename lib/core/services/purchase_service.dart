import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static const _apiKey = 'goog_xxxxxxxxxxxxxxxxxxxxxxxxxxx'; // Placeholder

  Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);

    // PurchasesConfiguration configuration;
    // if (Platform.isAndroid) {
    //   configuration = PurchasesConfiguration(_apiKey);
    // } else {
    //   configuration = PurchasesConfiguration(_apiKey); // Placeholder for iOS
    // }
    
    // await Purchases.configure(configuration);
  }

  Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all['premium']?.isActive ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } on PlatformException catch (_) {
      // Handle error
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    try {
        final purchaseResult = await Purchases.purchasePackage(package);
        return purchaseResult.customerInfo.entitlements.all['premium']?.isActive ?? false;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        // Handle error
      }
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } on PlatformException catch (_) {
      // Handle error
    }
  }
}
