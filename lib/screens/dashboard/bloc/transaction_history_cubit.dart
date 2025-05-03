import 'package:deuro_wallet/models/transaction.dart';
import 'package:deuro_wallet/packages/repository/transaction_repository.dart';
import 'package:deuro_wallet/packages/utils/default_assets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionHistoryCubit extends Cubit<List<Transaction>> {
  TransactionHistoryCubit(this._repository) : super([]) {
    _repository.watchTransactionsOfAssets([dEUROAsset], 6).listen(emit);
  }

  final TransactionRepository _repository;
}
