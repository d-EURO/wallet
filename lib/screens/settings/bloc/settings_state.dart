part of 'settings_bloc.dart';

final class SettingsState {
  const SettingsState({this.hideAmounts = false});

  final bool hideAmounts;

  SettingsState copyWith({
    bool? hideAmounts,
  }) {
    return SettingsState(
      hideAmounts: hideAmounts ?? this.hideAmounts,
    );
  }
}
