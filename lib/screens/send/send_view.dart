import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/packages/wallet/is_evm_address.dart';
import 'package:deuro_wallet/screens/send/bloc/send_bloc.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/widgets/amount_info_row.dart';
import 'package:deuro_wallet/widgets/blockchain_selector.dart';
import 'package:deuro_wallet/widgets/number_pad.dart';
import 'package:deuro_wallet/widgets/standard_slide_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SendView extends StatelessWidget {
  SendView({super.key, String? receiver})
      : receiverController = TextEditingController(text: receiver);

  static const _kPadding = EdgeInsets.only(left: 26, right: 26, bottom: 10);

  final TextEditingController receiverController;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: DEuroColors.anthracite,
              size: 24,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<SendBloc, SendState>(builder: (context, state) {
            return Column(children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 26, right: 26, top: 26, bottom: 10),
                child: TextField(
                  controller: receiverController,
                  onChanged: (receiver) =>
                      context.read<SendBloc>().add(ReceiverChanged(receiver)),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.deny(RegExp(r" ")),
                  ],
                  decoration: InputDecoration(
                    hintText: S.of(context).receiver,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: DEuroColors.dEuroBlue),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: DEuroColors.dEuroBlue),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  // suffix: SizedBox(
                  //   height: 55,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                  //     child: Row(
                  //       children: [
                  //         if (DeviceInfo.instance.isMobile)
                  //           IconButton(
                  //             onPressed: () => _presentQRScanner(context),
                  //             icon: const Icon(Icons.qr_code),
                  //           ),
                  //         IconButton(
                  //           onPressed: _openAddressBook,
                  //           icon: const Icon(CupertinoIcons.book),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ),
              ),
              if (state.receiver.isEthereumAddress) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 26, right: 26, top: 10),
                  child: Text(
                    "${state.amount.toString()} €",
                    style: const TextStyle(fontSize: 60),
                    textAlign: TextAlign.center,
                  ),
                ),
                Spacer(),
                BlockchainSelector(
                  onPressed: (blockchain) => context
                      .read<SendBloc>()
                      .add(ChainChanged(blockchain)),
                  blockchain: state.blockchain,
                  padding: _kPadding,
                ),
                AmountInfoRow(
                  padding: _kPadding,
                  title: S.of(context).fee,
                  amountString: state.fee,
                  currencySymbol: state.blockchain.nativeSymbol,
                ),
                NumberPad(
                  onNumberPressed: (index) =>
                      context.read<SendBloc>().add(AmountChangedAdd(index)),
                  onDeletePressed: () =>
                      context.read<SendBloc>().add(AmountChangedDelete()),
                  onDecimalPressed: () =>
                      context.read<SendBloc>().add(AmountChangedDecimal()),
                ),
                Padding(
                  padding: _kPadding,
                  child: StandardSlideButton(
                    onSlideComplete: () =>
                        context.read<SendBloc>().add(SendSubmitted()),
                    buttonText: S.of(context).send,
                  ),
                )
              ],
            ]);
          }),
        ),
      );
}
