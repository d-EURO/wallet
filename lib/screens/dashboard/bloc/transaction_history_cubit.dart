import 'package:deuro_wallet/models/transaction.dart';
import 'package:deuro_wallet/packages/repository/transaction_repository.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionHistoryState {}

class TransactionHistoryCubit extends Cubit<List<Transaction>> {
  TransactionHistoryCubit(this._repository) : super([]) {
    _repository.watchTransactionsOfAssets([dEUROAsset]).listen(emit);
  }

  final TransactionRepository _repository;
}
