import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsSeedCubit extends Cubit<bool> {
  SettingsSeedCubit(this.seed) : super(true);

  final String seed;

  void toggleShowSeed() => emit(!state);
}
