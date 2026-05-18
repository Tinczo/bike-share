import 'dart:async';

import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/core/util/input_converter.dart';
import 'package:bike_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:bike_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:bike_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:bike_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GetConcreteNumberTrivia>(),
  MockSpec<GetRandomNumberTrivia>(),
  MockSpec<InputConverter>(),
])
void main() {
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;
  late NumberTriviaBloc bloc;
  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initial state should be Empty', () async {
    // arrange

    // act

    // assert
    expect(bloc.state, isA<Empty>());
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() {
      when(
        mockInputConverter.stringToUnsignedInteger(any),
      ).thenReturn(Right(tNumberParsed));
    }

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(
          mockGetConcreteNumberTrivia(any),
        ).thenAnswer((_) async => Right(tNumberTrivia));

        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
        // assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    test('should emit [Error] when the input is invalid', () async {
      // arrange
      when(
        mockInputConverter.stringToUnsignedInteger(any),
      ).thenReturn(Left(InvalidInputFailure()));
      // assert later
      final expected = [Error(message: INVALID_INPUT_FAILURE_MESSAGE)];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete use case', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(
        mockGetConcreteNumberTrivia(any),
      ).thenAnswer((_) async => Right(tNumberTrivia));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));
      // assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(
          mockGetConcreteNumberTrivia(any),
        ).thenAnswer((_) async => Right(tNumberTrivia));
        // act// assert
        final expected = [Loading(), Loaded(trivia: tNumberTrivia)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // assertx
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test('should emit [Loading, Error] when getting data fails', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(
        mockGetConcreteNumberTrivia(any),
      ).thenAnswer((_) async => Left(ServerFailure()));
      // act// assert
      final expected = [Loading(), Error(message: SERVER_FAILURE_MESSAGE)];
      expectLater(bloc.stream, emitsInOrder(expected));
      // assertx
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test(
      'should emit [Loading, Error] with proper error message when getting data fails',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(
          mockGetConcreteNumberTrivia(any),
        ).thenAnswer((_) async => Left(CacheFailure()));
        // act// assert
        final expected = [Loading(), Error(message: CACHE_FAILURE_MESSAGE)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // assertx
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );

    test(
      'should ignore subsequent events when a previous event is still processing (droppable)',
      () async {
        // arrange
        final completer = Completer<Either<Failure, NumberTrivia>>();
        when(
          mockGetConcreteNumberTrivia(any),
        ).thenAnswer((_) => completer.future);
        setUpMockInputConverterSuccess();

        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        // assert
        await Future.delayed(Duration.zero);
        verify(
          mockGetConcreteNumberTrivia(Params(number: tNumberParsed)),
        ).called(1);

        // clean up
        completer.complete(Right(tNumberTrivia));
      },
    );
  });
  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 123, text: 'test trivia');

    test('should get data from the random use case', () async {
      // arrange
      when(
        mockGetRandomNumberTrivia(any),
      ).thenAnswer((_) async => Right(tNumberTrivia));
      // act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(any));
      // assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        when(
          mockGetRandomNumberTrivia(any),
        ).thenAnswer((_) async => Right(tNumberTrivia));
        // act// assert
        final expected = [Loading(), Loaded(trivia: tNumberTrivia)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // assertx
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test('should emit [Loading, Error] when getting data fails', () async {
      // arrange
      when(
        mockGetRandomNumberTrivia(any),
      ).thenAnswer((_) async => Left(ServerFailure()));
      // act// assert
      final expected = [Loading(), Error(message: SERVER_FAILURE_MESSAGE)];
      expectLater(bloc.stream, emitsInOrder(expected));
      // assertx
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
      'should emit [Loading, Error] with proper error message when getting data fails',
      () async {
        // arrange
        when(
          mockGetRandomNumberTrivia(any),
        ).thenAnswer((_) async => Left(CacheFailure()));
        // act// assert
        final expected = [Loading(), Error(message: CACHE_FAILURE_MESSAGE)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // assertx
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should ignore subsequent events when a previous event is still processing (droppable)',
      () async {
        // arrange
        final completer = Completer<Either<Failure, NumberTrivia>>();
        when(
          mockGetRandomNumberTrivia(any),
        ).thenAnswer((_) => completer.future);

        // act
        bloc.add(GetTriviaForRandomNumber());
        bloc.add(GetTriviaForRandomNumber());
        bloc.add(GetTriviaForRandomNumber());
        bloc.add(GetTriviaForRandomNumber());

        // assert
        await Future.delayed(Duration.zero);
        verify(mockGetRandomNumberTrivia(NoParams())).called(1);

        // clean up
        completer.complete(Right(tNumberTrivia));
      },
    );
  });
}
