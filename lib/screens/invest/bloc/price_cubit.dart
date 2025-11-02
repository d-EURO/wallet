import 'package:deuro_wallet/models/asset.dart';
import 'package:deuro_wallet/models/price_point.dart';
import 'package:deuro_wallet/packages/repository/price_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PriceCubit extends Cubit<List<PricePoint>> {
  PriceCubit(this.repository, this.asset) : super([]);

  final PriceRepository repository;
  final Asset asset;

  Future<void> loadPrice() => repository.getPrices(asset).then(emit);
}
