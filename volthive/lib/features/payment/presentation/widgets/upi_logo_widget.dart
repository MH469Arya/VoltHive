import 'package:flutter/material.dart';

/// Returns the correct logo widget for a given UPI app name.
Widget upiAppLogo(String appName, {double size = 40}) {
  String assetPath;
  switch (appName) {
    case 'GPay':
      assetPath = 'assets/logos/gpay.png';
      break;
    case 'PhonePe':
      assetPath = 'assets/logos/phonepe.png';
      break;
    case 'Paytm':
      assetPath = 'assets/logos/paytm.png';
      break;
    case 'BHIM':
      assetPath = 'assets/logos/bhim.png';
      break;
    default:
      return Icon(Icons.account_balance_wallet, size: size, color: Colors.grey);
  }

  return Image.asset(
    assetPath,
    width: size,
    height: size,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) =>
        Icon(Icons.broken_image, size: size, color: Colors.grey),
  );
}
