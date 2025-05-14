part of 'settings_bloc.dart';

final class SettingsState {
  const SettingsState({this.hideAmounts = false, this.language = Language.en});

  final bool hideAmounts;
  final Language language;

  SettingsState copyWith({
    bool? hideAmounts,
    Language? language,
  }) {
    return SettingsState(
      hideAmounts: hideAmounts ?? this.hideAmounts,
      language: language ?? this.language,
    );
  }
}
