import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/wallet/domain/entities/payment_method.dart';
import 'package:bike_app/features/wallet/domain/entities/transaction.dart';
import 'package:bike_app/features/wallet/domain/entities/wallet.dart';
import 'package:bike_app/features/wallet/domain/usecases/add_payment_method.dart';
import 'package:bike_app/features/wallet/domain/usecases/get_payment_methods.dart';
import 'package:bike_app/features/wallet/domain/usecases/get_transactions.dart';
import 'package:bike_app/features/wallet/domain/usecases/get_wallet.dart';
import 'package:bike_app/features/wallet/domain/usecases/top_up_wallet.dart';
import 'package:bike_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetWallet extends Mock implements GetWallet {}

class MockGetTransactions extends Mock implements GetTransactions {}

class MockTopUpWallet extends Mock implements TopUpWallet {}

class MockGetPaymentMethods extends Mock implements GetPaymentMethods {}

class MockAddPaymentMethod extends Mock implements AddPaymentMethod {}

void main() {
  late WalletBloc bloc;
  late MockGetWallet mockGetWallet;
  late MockGetTransactions mockGetTransactions;
  late MockTopUpWallet mockTopUpWallet;
  late MockGetPaymentMethods mockGetPaymentMethods;
  late MockAddPaymentMethod mockAddPaymentMethod;

  setUp(() {
    mockGetWallet = MockGetWallet();
    mockGetTransactions = MockGetTransactions();
    mockTopUpWallet = MockTopUpWallet();
    mockGetPaymentMethods = MockGetPaymentMethods();
    mockAddPaymentMethod = MockAddPaymentMethod();
    bloc = WalletBloc(
      getWallet: mockGetWallet,
      getTransactions: mockGetTransactions,
      topUpWallet: mockTopUpWallet,
      getPaymentMethods: mockGetPaymentMethods,
      addPaymentMethod: mockAddPaymentMethod,
    );
  });

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(const TopUpParams(amount: 0, method: ''));
    registerFallbackValue(
      const AddPaymentMethodParams(
        paymentMethod: PaymentMethod(id: '', type: PaymentMethodType.card),
      ),
    );
  });

  tearDown(() => bloc.close());

  const tWallet = Wallet(
    balance: 100.0,
    status: WalletStatus.active,
    hasCard: true,
  );

  final tTransactions = [
    Transaction(
      id: '1',
      amount: 50.0,
      type: TransactionType.topUp,
      date: DateTime(2024, 1, 15),
      description: 'Top up via BLIK',
    ),
  ];

  const tPaymentMethods = [
    PaymentMethod(
      id: '1',
      type: PaymentMethodType.card,
      lastFourDigits: '4242',
      cardBrand: 'Visa',
    ),
  ];

  test('initial state should be WalletInitial', () {
    expect(bloc.state, const WalletInitial());
  });

  group('WalletLoadRequested', () {
    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletLoaded] when data is loaded successfully',
      build: () {
        when(
          () => mockGetWallet(any()),
        ).thenAnswer((_) async => const Right(tWallet));
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer((_) async => Right(tTransactions));
        when(
          () => mockGetPaymentMethods(any()),
        ).thenAnswer((_) async => const Right(tPaymentMethods));
        return bloc;
      },
      act: (bloc) => bloc.add(const WalletLoadRequested()),
      expect: () => [
        const WalletLoading(),
        WalletLoaded(
          wallet: tWallet,
          transactions: tTransactions,
          paymentMethods: tPaymentMethods,
        ),
      ],
      verify: (_) {
        verify(() => mockGetWallet(any())).called(1);
        verify(() => mockGetTransactions(any())).called(1);
        verify(() => mockGetPaymentMethods(any())).called(1);
      },
    );

    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletError] when getWallet fails',
      build: () {
        when(
          () => mockGetWallet(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer((_) async => Right(tTransactions));
        when(
          () => mockGetPaymentMethods(any()),
        ).thenAnswer((_) async => const Right(tPaymentMethods));
        return bloc;
      },
      act: (bloc) => bloc.add(const WalletLoadRequested()),
      expect: () => [
        const WalletLoading(),
        const WalletError('Server error. Please try again later.'),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletError] on network failure',
      build: () {
        when(
          () => mockGetWallet(any()),
        ).thenAnswer((_) async => Left(NetworkFailure()));
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer((_) async => Right(tTransactions));
        when(
          () => mockGetPaymentMethods(any()),
        ).thenAnswer((_) async => const Right(tPaymentMethods));
        return bloc;
      },
      act: (bloc) => bloc.add(const WalletLoadRequested()),
      expect: () => [
        const WalletLoading(),
        const WalletError('No internet connection'),
      ],
    );
  });

  group('TopUpRequested', () {
    blocTest<WalletBloc, WalletState>(
      'emits [WalletTopUpInProgress, WalletTopUpSuccess] on successful top up',
      build: () {
        when(
          () => mockTopUpWallet(any()),
        ).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const TopUpRequested(amount: 50.0, method: 'blik')),
      expect: () => [const WalletTopUpInProgress(), const WalletTopUpSuccess()],
      verify: (_) {
        verify(() => mockTopUpWallet(any())).called(1);
      },
    );

    blocTest<WalletBloc, WalletState>(
      'emits [WalletTopUpInProgress, WalletError] when top up fails',
      build: () {
        when(
          () => mockTopUpWallet(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const TopUpRequested(amount: 50.0, method: 'blik')),
      expect: () => [
        const WalletTopUpInProgress(),
        const WalletError('Server error. Please try again later.'),
      ],
    );
  });

  group('PaymentMethodsLoadRequested', () {
    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, PaymentMethodsLoaded] on success',
      build: () {
        when(
          () => mockGetPaymentMethods(any()),
        ).thenAnswer((_) async => const Right(tPaymentMethods));
        return bloc;
      },
      act: (bloc) => bloc.add(const PaymentMethodsLoadRequested()),
      expect: () => [
        const WalletLoading(),
        const PaymentMethodsLoaded(tPaymentMethods),
      ],
    );

    blocTest<WalletBloc, WalletState>(
      'emits [WalletLoading, WalletError] on failure',
      build: () {
        when(
          () => mockGetPaymentMethods(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const PaymentMethodsLoadRequested()),
      expect: () => [
        const WalletLoading(),
        const WalletError('Server error. Please try again later.'),
      ],
    );
  });
}
