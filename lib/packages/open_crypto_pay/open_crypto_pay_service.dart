import 'dart:convert';
import 'dart:developer';

import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/open_crypto_pay/exceptions.dart';
import 'package:deuro_wallet/packages/open_crypto_pay/lnurl.dart';
import 'package:deuro_wallet/packages/open_crypto_pay/models.dart';
import 'package:http/http.dart';

class OpenCryptoPayService {
  static bool isOpenCryptoPayQR(String value) =>
      value.toLowerCase().contains("lightning=lnurl") ||
      value.toLowerCase().startsWith("lnurl");

  final Client _httpClient = Client();

  Future<String> commitOpenCryptoPayRequest(
    String txHex, {
    required String txId,
    required OpenCryptoPayRequest request,
    required Asset asset,
  }) async {
    final uri = Uri.parse(request.callbackUrl.replaceAll("/cb/", "/tx/"));

    final queryParams = Map.of(uri.queryParameters);

    queryParams['quote'] = request.quote;
    queryParams['asset'] = asset.name;
    queryParams['method'] = _getMethod(asset);
    queryParams['hex'] = txHex;
    queryParams['tx'] = txId;

    final response =
        await _httpClient.get(Uri.https(uri.authority, uri.path, queryParams));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map;

      if (body.keys.contains("txId")) return body["txId"] as String;
      throw OpenCryptoPayException(body.toString());
    }
    throw OpenCryptoPayException(
        "Unexpected status code ${response.statusCode} ${response.body}");
  }

  Future<void> cancelOpenCryptoPayRequest(OpenCryptoPayRequest request) async {
    final uri = Uri.parse(request.callbackUrl.replaceAll("/cb/", "/cancel/"));

    await _httpClient.delete(uri);
  }

  Future<OpenCryptoPayRequest> getOpenCryptoPayInvoice(String lnUrl) async {
    if (lnUrl.toLowerCase().startsWith("http")) {
      final uri = Uri.parse(lnUrl);
      final params = uri.queryParameters;
      if (!params.containsKey("lightning")) {
        throw OpenCryptoPayNotSupportedException(uri.authority);
      }

      lnUrl = params["lightning"] as String;
    }
    final url = decodeLNURL(lnUrl);
    final params = await _getOpenCryptoPayParams(url);

    return OpenCryptoPayRequest(
      receiverName: params.$1.displayName ?? "Unknown",
      expiry: params.$1.expiration.difference(DateTime.now()).inSeconds,
      callbackUrl: params.$1.callbackUrl,
      amount: BigInt.parse(params.$1.amount),
      quote: params.$1.id,
      methods: params.$2,
    );
  }

  Future<(_OpenCryptoPayQuote, Map<String, List<OpenCryptoPayQuoteAsset>>)>
      _getOpenCryptoPayParams(Uri uri) async {
    final response = await _httpClient.get(uri);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map;

      for (final key in ['callback', 'transferAmounts', 'quote']) {
        if (!responseBody.keys.contains(key)) {
          throw OpenCryptoPayNotSupportedException(uri.authority);
        }
      }

      final methods = <String, List<OpenCryptoPayQuoteAsset>>{};
      for (final transferAmountRaw in responseBody['transferAmounts'] as List) {
        final transferAmount = transferAmountRaw as Map;
        final method = transferAmount['method'] as String;
        methods[method] = [];
        for (final assetJson in transferAmount['assets'] as List) {
          final asset = OpenCryptoPayQuoteAsset.fromJson(
              assetJson as Map<String, dynamic>);
          methods[method]?.add(asset);
        }
      }

      log(responseBody.toString());

      final quote = _OpenCryptoPayQuote.fromJson(
          responseBody['callback'] as String,
          responseBody['displayName'] as String?,
          responseBody['quote'] as Map<String, dynamic>);

      return (quote, methods);
    } else {
      throw OpenCryptoPayException(
          'Failed to get Open CryptoPay Request. Status: ${response.statusCode} ${response.body}');
    }
  }

  Future<Uri> getOpenCryptoPayAddress(
      OpenCryptoPayRequest request, Asset asset) async {
    final uri = Uri.parse(request.callbackUrl);
    final queryParams = Map.of(uri.queryParameters);

    queryParams['quote'] = request.quote;
    queryParams['asset'] = asset.name;
    queryParams['method'] = _getMethod(asset);

    final response =
        await _httpClient.get(Uri.https(uri.authority, uri.path, queryParams));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map;

      for (final key in ['expiryDate', 'uri']) {
        if (!responseBody.keys.contains(key)) {
          throw OpenCryptoPayNotSupportedException(uri.authority);
        }
      }

      final result = Uri.parse(responseBody['uri'] as String);

      if (result.queryParameters['amount'] != null) return result;

      final newQueryParameters =
          Map<String, dynamic>.from(result.queryParameters);

      newQueryParameters['amount'] = _getAmountByAsset(request, asset);
      return Uri(
          scheme: result.scheme,
          path: result.path.split("@").first,
          queryParameters: newQueryParameters);
    } else {
      throw OpenCryptoPayException(
          'Failed to create Open CryptoPay Request. Status: ${response.statusCode} ${response.body}');
    }
  }

  String _getAmountByAsset(OpenCryptoPayRequest request, Asset asset) {
    final method = _getMethod(asset);
    return request.methods[method]!
        .firstWhere((e) => e.symbol.toUpperCase() == asset.name.toUpperCase())
        .amount;
  }

  String _getMethod(Asset asset) =>
      Blockchain.getFromChainId(asset.chainId).name;
}

class _OpenCryptoPayQuote {
  final String callbackUrl;
  final String? displayName;
  final String id;
  final DateTime expiration;
  final String amount;

  _OpenCryptoPayQuote(this.callbackUrl, this.displayName, this.id,
      this.expiration, this.amount);

  _OpenCryptoPayQuote.fromJson(
      this.callbackUrl, this.displayName, Map<String, dynamic> json)
      : id = json['id'] as String,
        amount = '0',
        expiration = DateTime.parse(json['expiration'] as String);
}
