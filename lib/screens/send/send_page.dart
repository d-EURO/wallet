import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/screens/send/bloc/send_bloc.dart';
import 'package:deuro_wallet/screens/send/send_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendPage extends StatelessWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SendBloc(getIt<AppStore>(), dEUROAsset),
    child: SendView(),
  );
}
