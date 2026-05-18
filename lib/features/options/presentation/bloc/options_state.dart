part of 'options_bloc.dart';

sealed class OptionsState extends Equatable {
  const OptionsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
final class OptionsInitial extends OptionsState {
  const OptionsInitial();
}

/// Loading state while fetching options.
final class OptionsLoading extends OptionsState {
  const OptionsLoading();
}

/// State when options are successfully loaded.
final class OptionsLoaded extends OptionsState {
  final ApiOptions options;
  final bool hasChanges;

  const OptionsLoaded({required this.options, this.hasChanges = false});

  @override
  List<Object?> get props => [options, hasChanges];
}

/// State when options are being saved.
final class OptionsSaving extends OptionsState {
  const OptionsSaving();
}

/// State when options are successfully saved.
final class OptionsSaved extends OptionsState {
  final ApiOptions options;

  const OptionsSaved({required this.options});

  @override
  List<Object?> get props => [options];
}

/// Error state with a message.
final class OptionsError extends OptionsState {
  final String message;

  const OptionsError(this.message);

  @override
  List<Object?> get props => [message];
}
