import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/models/blockchain.dart';
import 'package:deuro_wallet/packages/utils/format_fixed.dart';
import 'package:deuro_wallet/screens/send_invoice/bloc/expiry_cubit.dart';
import 'package:deuro_wallet/screens/send_invoice/bloc/send_invoice_bloc.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/widgets/amount_info_row.dart';
import 'package:deuro_wallet/widgets/blockchain_selector.dart';
import 'package:deuro_wallet/widgets/info_row.dart';
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
            onPressed: () {
              context.read<SendInvoiceBloc>().add(CancelInvoice());
              context.pop();
            },
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
                BlocBuilder<ExpiryCubit, ExpiryState>(
                  bloc: context.read<SendInvoiceBloc>().expiryCubit,
                  builder: (context, state) => Column(
                    children: [
                      InfoRow(
                        padding: _kPadding,
                        leading: S.of(context).fee,
                        trailing: "${state.secondsRemaining} Seconds",
                      ),
                      Padding(
                        padding: _kPadding,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: FilledButton(
                                    onPressed: () => context
                                        .read<SendInvoiceBloc>()
                                        .add(CancelInvoice()),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      fixedSize: Size(double.infinity, 55),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.xmark,
                                      color: Colors.white,
                                      size: 19,
                                    )),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: () => context
                                    .read<SendInvoiceBloc>()
                                    .add(SendSubmitted()),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  fixedSize: Size(double.infinity, 55),
                                ),
                                child: true
                                    ? Text(
                                  "Pay",
                                  style: const TextStyle(fontSize: 16),
                                )
                                    : const CupertinoActivityIndicator(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      );
}
