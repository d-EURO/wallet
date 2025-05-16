class OpenCryptoPayRequest {
  final String amount;
  final String amountSymbol;
  final String receiverName;
  final int expiry;
  final String callbackUrl;
  final String quote;
  final Map<String, List<OpenCryptoPayQuoteAsset>> methods;


  const OpenCryptoPayRequest({
    required this.amount,
    required this.amountSymbol,
    required this.receiverName,
    required this.expiry,
    required this.callbackUrl,
    required this.quote,
    required this.methods,
  });
}

class OpenCryptoPayQuoteAsset {
  final String symbol;
  final String amount;
  final int gasFee;

  const OpenCryptoPayQuoteAsset(this.symbol, this.amount, this.gasFee);

  OpenCryptoPayQuoteAsset.fromJson(Map<String, dynamic> json, this.gasFee)
      : symbol = json['asset'] as String,
        amount = json['amount'] as String;
}
