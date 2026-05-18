import 'package:bike_app/core/error/failures.dart';
import 'package:bike_app/core/usecases/usecase.dart';
import 'package:bike_app/features/auth/domain/entities/user.dart';
import 'package:bike_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:bike_app/features/auth/domain/usecases/login_user.dart';
import 'package:bike_app/features/auth/domain/usecases/logout_user.dart';
import 'package:bike_app/features/auth/domain/usecases/register_user.dart';
import 'package:bike_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUser extends Mock implements LoginUser {}

class MockRegisterUser extends Mock implements RegisterUser {}

class MockLogoutUser extends Mock implements LogoutUser {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

void main() {
  late AuthBloc bloc;
  late MockLoginUser mockLoginUser;
  late MockRegisterUser mockRegisterUser;
  late MockLogoutUser mockLogoutUser;
  late MockGetCurrentUser mockGetCurrentUser;

  setUp(() {
    mockLoginUser = MockLoginUser();
    mockRegisterUser = MockRegisterUser();
    mockLogoutUser = MockLogoutUser();
    mockGetCurrentUser = MockGetCurrentUser();
    bloc = AuthBloc(
      loginUser: mockLoginUser,
      registerUser: mockRegisterUser,
      logoutUser: mockLogoutUser,
      getCurrentUser: mockGetCurrentUser,
    );
  });

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(const RegisterParams(email: '', password: ''));
    registerFallbackValue(NoParams());
  });

  tearDown(() {
    bloc.close();
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = User(id: '123', email: tEmail);

  test('initial state should be AuthInitial', () {
    expect(bloc.state, const AuthInitial());
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when user is cached',
      build: () {
        when(
          () => mockGetCurrentUser(any()),
        ).thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
      verify: (_) {
        verify(() => mockGetCurrentUser(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no user is cached',
      build: () {
        when(
          () => mockGetCurrentUser(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on failure',
      build: () {
        when(
          () => mockGetCurrentUser(any()),
        ).thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(
          () => mockLoginUser(any()),
        ).thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
      expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
      verify: (_) {
        verify(
          () => mockLoginUser(
            const LoginParams(email: tEmail, password: tPassword),
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when credentials are invalid',
      build: () {
        when(
          () => mockLoginUser(any()),
        ).thenAnswer((_) async => Left(InvalidCredentialsFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid email or password'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when network fails',
      build: () {
        when(
          () => mockLoginUser(any()),
        ).thenAnswer((_) async => Left(NetworkFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
      expect: () => [
        const AuthLoading(),
        const AuthError('No internet connection'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when server fails',
      build: () {
        when(
          () => mockLoginUser(any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
      expect: () => [
        const AuthLoading(),
        const AuthError('Server error. Please try again later.'),
      ],
    );
  });

  group('RegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when registration succeeds',
      build: () {
        when(
          () => mockRegisterUser(any()),
        ).thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const RegisterRequested(email: tEmail, password: tPassword)),
      expect: () => [const AuthLoading(), const AuthAuthenticated(tUser)],
      verify: (_) {
        verify(
          () => mockRegisterUser(
            const RegisterParams(email: tEmail, password: tPassword),
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when email is already in use',
      build: () {
        when(
          () => mockRegisterUser(any()),
        ).thenAnswer((_) async => Left(EmailAlreadyInUseFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const RegisterRequested(email: tEmail, password: tPassword)),
      expect: () => [
        const AuthLoading(),
        const AuthError('Email is already in use'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when network fails',
      build: () {
        when(
          () => mockRegisterUser(any()),
        ).thenAnswer((_) async => Left(NetworkFailure()));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const RegisterRequested(email: tEmail, password: tPassword)),
      expect: () => [
        const AuthLoading(),
        const AuthError('No internet connection'),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout succeeds',
      build: () {
        when(
          () => mockLogoutUser(any()),
        ).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
      verify: (_) {
        verify(() => mockLogoutUser(any())).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when logout fails',
      build: () {
        when(
          () => mockLogoutUser(any()),
        ).thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError('Failed to logout. Please try again.'),
      ],
    );
  });
}
