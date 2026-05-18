import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/base_url_provider.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/api_options.dart';
import '../../domain/usecases/get_api_options.dart';
import '../../domain/usecases/save_api_options.dart';

part 'options_event.dart';
part 'options_state.dart';

const String cacheFailureMessage = 'Failed to access settings storage';
const String unexpectedErrorMessage = 'An unexpected error occurred';

@lazySingleton
class OptionsBloc extends Bloc<OptionsEvent, OptionsState> {
  final GetApiOptions getApiOptions;
  final SaveApiOptions saveApiOptions;
  final BaseUrlProvider baseUrlProvider;

  OptionsBloc({
    required this.getApiOptions,
    required this.saveApiOptions,
    required this.baseUrlProvider,
  }) : super(const OptionsInitial()) {
    on<OptionsLoadRequested>(_onOptionsLoadRequested);
    on<OptionsSameForAllToggled>(_onSameForAllToggled);
    on<OptionsGlobalUrlChanged>(_onGlobalUrlChanged);
    on<OptionsIndividualUrlChanged>(_onIndividualUrlChanged);
    on<OptionsSaveRequested>(_onSaveRequested);
    on<OptionsResetRequested>(_onResetRequested);
  }

  Future<void> _onOptionsLoadRequested(
    OptionsLoadRequested event,
    Emitter<OptionsState> emit,
  ) async {
    emit(const OptionsLoading());

    final result = await getApiOptions(NoParams());

    result.fold(
      (failure) => emit(OptionsError(_mapFailureToMessage(failure))),
      (options) => emit(OptionsLoaded(options: options)),
    );
  }

  void _onSameForAllToggled(
    OptionsSameForAllToggled event,
    Emitter<OptionsState> emit,
  ) {
    final currentState = state;
    if (currentState is OptionsLoaded) {
      final updatedOptions = currentState.options.copyWith(
        sameForAll: event.sameForAll,
      );
      emit(OptionsLoaded(options: updatedOptions, hasChanges: true));
    }
  }

  void _onGlobalUrlChanged(
    OptionsGlobalUrlChanged event,
    Emitter<OptionsState> emit,
  ) {
    final currentState = state;
    if (currentState is OptionsLoaded) {
      final updatedOptions = currentState.options.copyWith(
        globalBaseUrl: event.url,
      );
      emit(OptionsLoaded(options: updatedOptions, hasChanges: true));
    }
  }

  void _onIndividualUrlChanged(
    OptionsIndividualUrlChanged event,
    Emitter<OptionsState> emit,
  ) {
    final currentState = state;
    if (currentState is OptionsLoaded) {
      ApiOptions updatedOptions;

      switch (event.type) {
        case DataSourceType.auth:
          updatedOptions = currentState.options.copyWith(
            authBaseUrl: event.url,
          );
        case DataSourceType.map:
          updatedOptions = currentState.options.copyWith(mapBaseUrl: event.url);
        case DataSourceType.rental:
          updatedOptions = currentState.options.copyWith(
            rentalBaseUrl: event.url,
          );
        case DataSourceType.wallet:
          updatedOptions = currentState.options.copyWith(
            walletBaseUrl: event.url,
          );
        case DataSourceType.account:
          updatedOptions = currentState.options.copyWith(
            accountBaseUrl: event.url,
          );
      }

      emit(OptionsLoaded(options: updatedOptions, hasChanges: true));
    }
  }

  Future<void> _onSaveRequested(
    OptionsSaveRequested event,
    Emitter<OptionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is OptionsLoaded) {
      emit(const OptionsSaving());

      final result = await saveApiOptions(currentState.options);

      result.fold(
        (failure) => emit(OptionsError(_mapFailureToMessage(failure))),
        (_) {
          // Refresh the BaseUrlProvider cache so data sources use new URLs
          baseUrlProvider.refreshCache();
          emit(OptionsSaved(options: currentState.options));
        },
      );
    }
  }

  void _onResetRequested(
    OptionsResetRequested event,
    Emitter<OptionsState> emit,
  ) {
    emit(const OptionsLoaded(options: ApiOptions.defaults(), hasChanges: true));
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      CacheFailure() => cacheFailureMessage,
      _ => unexpectedErrorMessage,
    };
  }
}
