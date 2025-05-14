import 'package:deuro_wallet/di.dart';
import 'package:deuro_wallet/packages/service/app_store.dart';
import 'package:deuro_wallet/screens/savings_edit/bloc/savings_edit_bloc.dart';
import 'package:deuro_wallet/screens/savings_edit/savings_edit_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavingsEditPage extends StatelessWidget {
  const SavingsEditPage({required this.isAdding, super.key});

  final bool isAdding;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => SavingsEditBloc(getIt<AppStore>(), isAdding),
        child: SavingsEditView(),
      );
}
