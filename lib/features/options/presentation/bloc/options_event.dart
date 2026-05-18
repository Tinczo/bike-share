part of 'options_bloc.dart';

sealed class OptionsEvent extends Equatable {
  const OptionsEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load saved options.
final class OptionsLoadRequested extends OptionsEvent {
  const OptionsLoadRequested();
}

/// Toggle the "same for all" option.
final class OptionsSameForAllToggled extends OptionsEvent {
  final bool sameForAll;

  const OptionsSameForAllToggled(this.sameForAll);

  @override
  List<Object?> get props => [sameForAll];
}

/// Change the global base URL.
final class OptionsGlobalUrlChanged extends OptionsEvent {
  final String url;

  const OptionsGlobalUrlChanged(this.url);

  @override
  List<Object?> get props => [url];
}

/// Change an individual data source URL.
final class OptionsIndividualUrlChanged extends OptionsEvent {
  final DataSourceType type;
  final String url;

  const OptionsIndividualUrlChanged({required this.type, required this.url});

  @override
  List<Object?> get props => [type, url];
}

/// Request to save current options.
final class OptionsSaveRequested extends OptionsEvent {
  const OptionsSaveRequested();
}

/// Request to reset options to defaults.
final class OptionsResetRequested extends OptionsEvent {
  const OptionsResetRequested();
}
