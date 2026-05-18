import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/features/wallet/domain/entities/payment_method.dart';
import 'package:bike_app/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bike_app/features/wallet/domain/usecases/add_payment_method.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late AddPaymentMethod usecase;
  late MockWalletRepository mockWalletRepository;

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    usecase = AddPaymentMethod(mockWalletRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const PaymentMethod(id: '', type: PaymentMethodType.card),
    );
  });

  const tPaymentMethod = PaymentMethod(
    id: '1',
    type: PaymentMethodType.card,
    lastFourDigits: '4242',
    cardBrand: 'Visa',
  );

  test('should add payment method via repository', () async {
    // arrange
    when(
      () => mockWalletRepository.addPaymentMethod(tPaymentMethod),
    ).thenAnswer((_) async => const Right(unit));

    // act
    final result = await usecase(
      const AddPaymentMethodParams(paymentMethod: tPaymentMethod),
    );

    // assert
    expect(result, const Right(unit));
    verify(
      () => mockWalletRepository.addPaymentMethod(tPaymentMethod),
    ).called(1);
    verifyNoMoreInteractions(mockWalletRepository);
  });

  test('should return failure when adding payment method fails', () async {
    // arrange
    when(
      () => mockWalletRepository.addPaymentMethod(tPaymentMethod),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(
      const AddPaymentMethodParams(paymentMethod: tPaymentMethod),
    );

    // assert
    expect(result, Left(ServerFailure()));
    verify(
      () => mockWalletRepository.addPaymentMethod(tPaymentMethod),
    ).called(1);
    verifyNoMoreInteractions(mockWalletRepository);
  });

  test('should return NetworkFailure when no network connection', () async {
    // arrange
    when(
      () => mockWalletRepository.addPaymentMethod(tPaymentMethod),
    ).thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase(
      const AddPaymentMethodParams(paymentMethod: tPaymentMethod),
    );

    // assert
    expect(result, Left(NetworkFailure()));
  });

  group('AddPaymentMethodParams', () {
    test('should support value equality', () {
      const params1 = AddPaymentMethodParams(paymentMethod: tPaymentMethod);
      const params2 = AddPaymentMethodParams(paymentMethod: tPaymentMethod);

      expect(params1, equals(params2));
    });

    test('props should contain payment method', () {
      const params = AddPaymentMethodParams(paymentMethod: tPaymentMethod);

      expect(params.props, [tPaymentMethod]);
    });
  });
}
