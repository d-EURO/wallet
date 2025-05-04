import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState()) {
    on<ToggleHideAmountEvent>(_onToggleHideAmountEvent);
  }

  void _onToggleHideAmountEvent(
      ToggleHideAmountEvent event, Emitter<SettingsState> emit) {
    print(state.hideAmounts);
    emit(state.copyWith(hideAmounts: !state.hideAmounts));
  }
}
