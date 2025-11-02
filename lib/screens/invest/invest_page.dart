import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/packages/repository/price_repository.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:deuro_wallet/screens/invest/bloc/price_cubit.dart';
import 'package:deuro_wallet/screens/invest/invest_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InvestPage extends StatelessWidget {
  const InvestPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) =>
            PriceCubit(getIt<PriceRepository>(), nDEPSAsset)..loadPrice(),
        child: InvestView(getIt<AppStore>()),
      );
}
