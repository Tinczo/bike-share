import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

@injectable
class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<NumberTriviaEvent>((event, emit) async {
      await switch (event) {
        GetTriviaForConcreteNumber() => _onConcrete(event, emit),
        GetTriviaForRandomNumber() => _onRandom(event, emit),
      };
    }, transformer: droppable());
  }

  Future<void> _onConcrete(
    GetTriviaForConcreteNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    final inputEither = inputConverter.stringToUnsignedInteger(
      event.numberString,
    );

    await inputEither.fold(
      (failure) async =>
          emit(const Error(message: INVALID_INPUT_FAILURE_MESSAGE)),
      (integer) async {
        emit(Loading());
        final result = await getConcreteNumberTrivia(Params(number: integer));
        _eitherLoadedOrFailureState(emit, result);
      },
    );
  }

  Future<void> _onRandom(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(Loading());
    final result = await getRandomNumberTrivia(NoParams());
    _eitherLoadedOrFailureState(emit, result);
  }

  void _eitherLoadedOrFailureState(
    Emitter<NumberTriviaState> emit,
    Either<Failure, NumberTrivia> failureOrTrivia,
  ) {
    failureOrTrivia.fold(
      (failure) => emit(Error(message: _mapFailureToMessage(failure))),
      (trivia) => emit(Loaded(trivia: trivia)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure() => SERVER_FAILURE_MESSAGE,
      CacheFailure() => CACHE_FAILURE_MESSAGE,
      _ => 'Unexpected Error',
    };
  }
}
