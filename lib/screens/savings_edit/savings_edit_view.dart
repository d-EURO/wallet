import 'package:deuro_wallet/generated/i18n.dart';
import 'package:deuro_wallet/screens/savings_edit/bloc/savings_edit_bloc.dart';
import 'package:deuro_wallet/screens/send/bloc/gas_fee_cubit.dart';
import 'package:deuro_wallet/styles/colors.dart';
import 'package:deuro_wallet/widgets/amount_info_row.dart';
import 'package:deuro_wallet/widgets/number_pad.dart';
import 'package:deuro_wallet/widgets/standard_slide_button_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SavingsEditView extends StatelessWidget {
  const SavingsEditView({super.key});

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
          border: null,
        ),
        body: SafeArea(
          child: BlocBuilder<SavingsEditBloc, SavingsEditState>(
            builder: (context, savingsEditState) => Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 26, right: 26, top: 10),
                child: Text(
                  "${savingsEditState.amount.toString()} €",
                  style: const TextStyle(fontSize: 60),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
              BlocBuilder<GasFeeCubit, GasFeeState>(
                bloc: context.read<SavingsEditBloc>().gasFeeCubit,
                builder: (context, state) => AmountInfoRow(
                  padding: _kPadding,
                  title: S.of(context).fee,
                  amountString: state.formatedFee,
                  currencySymbol: savingsEditState.blockchain.nativeSymbol,
                ),
              ),
              NumberPad(
                onNumberPressed: (i) =>
                    context.read<SavingsEditBloc>().add(AmountChangedAdd(i)),
                onDeletePressed: () =>
                    context.read<SavingsEditBloc>().add(AmountChangedDelete()),
                onDecimalPressed: () =>
                    context.read<SavingsEditBloc>().add(AmountChangedDecimal()),
              ),
              Padding(
                padding: _kPadding,
                child: StandardSlideButton(
                  onSlideComplete: () =>
                      context.read<SavingsEditBloc>().add(SendSubmitted()),
                  buttonText: context.read<SavingsEditBloc>().isAdding
                      ? S.of(context).savings_add
                      : S.of(context).savings_remove,
                ),
              )
            ]),
          ),
        ),
      );
}
