import 'package:deuro_wallet/widgets/handlebars.dart';
import 'package:flutter/material.dart';

class ErrorBottomSheet extends StatelessWidget {
  const ErrorBottomSheet({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 16),
                child: Handlebars.horizontal(context),
              ),
              CircleAvatar(
                backgroundColor: Colors.red,
                radius: 32,
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 46,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  message,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
}
