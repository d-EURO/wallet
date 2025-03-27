import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/packages/service/wallet_service.dart';
import 'package:deuro_wallet/screens/create_wallet/bloc/create_wallet_cubit.dart';
import 'package:deuro_wallet/screens/create_wallet/create_wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateWalletPage extends StatelessWidget {
  const CreateWalletPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) =>
            CreateWalletCubit(getIt<WalletService>())..createWallet(),
        child: CreateWalletView(),
      );
}
