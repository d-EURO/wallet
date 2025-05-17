import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/packages/open_crypto_pay/models.dart';
import 'package:deuro_wallet/packages/open_crypto_pay/open_crypto_pay_service.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/screens/send_invoice/bloc/send_invoice_bloc.dart';
import 'package:deuro_wallet/screens/send_invoice/send_invoice_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendInvoicePage extends StatelessWidget {
  final OpenCryptoPayRequest request;

  const SendInvoicePage({super.key, required this.request});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => SendInvoiceBloc(
          getIt<AppStore>(),
          getIt<OpenCryptoPayService>(),
          invoice: request,
        ),
        child: BlocProvider(
          create: (context) => context.read<SendInvoiceBloc>().expiryCubit,
          child: SendInvoiceView(),
        ),
      );
}
