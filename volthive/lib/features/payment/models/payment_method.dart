enum PaymentMethodType { upi, card, netBanking }

/// Represents a bank listed in the Net Banking tab.
class BankOption {
  final String name;
  final String code;
  final String logoAsset;

  const BankOption({
    required this.name,
    required this.code,
    required this.logoAsset,
  });
}

const List<BankOption> popularBanks = [
  BankOption(name: 'State Bank of India', code: 'SBI', logoAsset: 'assets/logos/sbi.png'),
  BankOption(name: 'HDFC Bank', code: 'HDFC', logoAsset: 'assets/logos/hdfc.png'),
  BankOption(name: 'ICICI Bank', code: 'ICICI', logoAsset: 'assets/logos/icici.png'),
  BankOption(name: 'Axis Bank', code: 'AXIS', logoAsset: 'assets/logos/axis.png'),
  BankOption(name: 'Kotak Mahindra', code: 'KOTAK', logoAsset: 'assets/logos/kotak.png'),
];

/// Popular UPI apps shown as quick-select tiles.
class UpiApp {
  final String name;

  const UpiApp({required this.name});
}

const List<UpiApp> upiApps = [
  UpiApp(name: 'GPay'),
  UpiApp(name: 'PhonePe'),
  UpiApp(name: 'Paytm'),
  UpiApp(name: 'BHIM'),
];
