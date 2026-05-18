import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/rental_history_item.dart';
import '../../domain/usecases/get_rental_history.dart';

part 'rental_history_event.dart';
part 'rental_history_state.dart';

@injectable
class RentalHistoryBloc extends Bloc<RentalHistoryEvent, RentalHistoryState> {
  final GetRentalHistory getRentalHistory;

  RentalHistoryBloc({required this.getRentalHistory})
    : super(const RentalHistoryInitial()) {
    on<RentalHistoryLoadRequested>(_onRentalHistoryLoadRequested);
  }

  Future<void> _onRentalHistoryLoadRequested(
    RentalHistoryLoadRequested event,
    Emitter<RentalHistoryState> emit,
  ) async {
    emit(const RentalHistoryLoading());

    final result = await getRentalHistory(NoParams());

    result.fold(
      (failure) => emit(RentalHistoryError(_mapFailureToMessage(failure))),
      (rentalHistory) {
        if (rentalHistory.isEmpty) {
          emit(const RentalHistoryEmpty());
        } else {
          emit(RentalHistoryLoaded(rentalHistory));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure() => 'No internet connection',
      ServerFailure() => 'Server error. Please try again later.',
      _ => 'An unexpected error occurred',
    };
  }
}
