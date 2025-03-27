import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/screens/restore_wallet/bloc/restore_wallet_cubit.dart';
import 'package:deuro_wallet/screens/restore_wallet/restore_wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RestoreWalletPage extends StatelessWidget {
  const RestoreWalletPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<RestoreWalletCubit>(),
        child: RestoreWalletView(),
      );
}
