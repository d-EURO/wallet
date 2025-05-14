part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

final class ToggleHideAmountEvent extends SettingsEvent {
  const ToggleHideAmountEvent();
}

final class SetLanguageEvent extends SettingsEvent {
  final Language language;

  const SetLanguageEvent(this.language);

  @override
  List<Object> get props => [language];
}
