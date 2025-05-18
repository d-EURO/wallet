import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/wallet/payment_uri.dart';
import 'package:deuro_wallet/screens/receive/widgets/qr_address_widget.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/widgets/handlebars.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key, this.isBottomSheet = true});

  final bool isBottomSheet;

  @override
  Widget build(BuildContext context) {
    final address = getIt<AppStore>().primaryAddress;

    return Scaffold(
      appBar: isBottomSheet ? null : AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: DEuroColors.anthracite,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isBottomSheet) Handlebars.horizontal(context),
            SizedBox(width: double.infinity, height: isBottomSheet ? 20 : 0,),
            QRAddressWidget(
              uri: EthereumURI(address: address, amount: '').toString(),
              subtitle: address,
            ),
            // if (_appStore.dfxAuthToken != null) ...[
            //   OptionCard(
            //     title: S.of(context).deposit_with_bank_transfer,
            //     description: S.of(context).deposit_with_bank_transfer_description,
            //     leadingIcon: Icons.money,
            //     action: () => getIt
            //         .get<DFXService>()
            //         .launchProvider(context, true, paymentMethod: "bank"),
            //   ),
            //   OptionCard(
            //     title: S.of(context).deposit_with_card,
            //     description: S.of(context).deposit_with_card_description,
            //     leadingIcon: Icons.credit_card,
            //     action: () => getIt
            //         .get<DFXService>()
            //         .launchProvider(context, true, paymentMethod: "card"),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}
