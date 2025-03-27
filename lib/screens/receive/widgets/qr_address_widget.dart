import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRAddressWidget extends StatelessWidget {
  const QRAddressWidget({super.key, required this.uri, required this.subtitle});

  final String uri;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          QrImageView(
            data: uri,
            // errorCorrectionLevel: errorCorrectionLevel,
            size: 300,
            eyeStyle: const QrEyeStyle(color: Colors.white),
            dataModuleStyle: const QrDataModuleStyle(
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: InkWell(
              enableFeedback: false,
              onTap: _copyToClipboard,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: subtitle.substring(0, 6),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: " "),
                        TextSpan(
                          text: subtitle.substring(6, 21),
                        ),
                        const TextSpan(text: "\n"),
                        TextSpan(
                          text: subtitle.substring(21, 36),
                        ),
                        const TextSpan(text: " "),
                        TextSpan(
                          text: subtitle.substring(36),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ]),
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Monospace',
                        color: Colors.white,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  Future<void> _copyToClipboard() =>
      Clipboard.setData(ClipboardData(text: uri));
}
