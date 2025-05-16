import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/screens/send_invoice/bloc/send_invoice_bloc.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/widgets/amount_info_row.dart';
import 'package:deuro_wallet/widgets/blockchain_selector.dart';
import 'package:deuro_wallet/widgets/standard_slide_button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SendInvoiceView extends StatelessWidget {
  const SendInvoiceView({super.key});

  static const _kPadding = EdgeInsets.only(left: 26, right: 26, bottom: 10);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CupertinoNavigationBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: DEuroColors.anthracite,
              size: 24,
            ),
          ),
          middle: Text(
            "Open CryptoPay",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Satoshi',
            ),
          ),
          border: null,
        ),
        body: SafeArea(
          child: BlocBuilder<SendInvoiceBloc, SendInvoiceState>(
              builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
                  child: Text(
                    state.invoice.receiverName,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Text(
                  "${state.invoice.amount} ${state.invoice.amountSymbol}",
                  style: const TextStyle(fontSize: 60),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "${formatFixed(state.dEuroAmount, 18, fractionalDigits: 2)} dEuro",
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                BlockchainSelector(
                  onPressed: () => context
                      .read<SendInvoiceBloc>()
                      .add(ChainChanged(Blockchain.optimism)),
                  blockchain: state.blockchain,
                  padding: _kPadding,
                ),
                AmountInfoRow(
                  padding: _kPadding,
                  title: S.of(context).fee,
                  amountString: state.fee,
                  currencySymbol: state.blockchain.nativeSymbol,
                ),
                Padding(
                  padding: _kPadding,
                  child: StandardSlideButton(
                    onSlideComplete: () =>
                        context.read<SendInvoiceBloc>().add(SendSubmitted()),
                    buttonText: S.of(context).send,
                  ),
                )
              ],
            );
          }),
        ),
      );
}
