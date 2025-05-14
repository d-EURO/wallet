import 'package:deuro_wallet/screens/savings/bloc/savings_bloc.dart';
import 'package:deuro_wallet/screens/savings/widgets/section_balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavingsView extends StatelessWidget {
  const SavingsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          top: false,
          child: BlocBuilder<SavingsBloc, SavingsState>(
            builder: (context, state) => Column(children: [
              SectionBalance(
                balance: BigInt.parse(state.amount, radix: 16),
                collectedInterest: BigInt.parse(state.interest, radix: 16),
                isEnabled: state.isEnabled,
              ),
            ]),
          ),
        ),
      );
}
