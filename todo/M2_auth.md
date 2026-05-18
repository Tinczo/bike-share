# M2: Authentication Feature

**Goal:** Implement full authentication flow.
**Ref:** `docs/02_requirements_functional.md` (3.1)
**Ref:** `docs/05_ui_ux.md` (6.1)

- [x] **Domain Layer**
  - [x] Entity: `User` (`lib/features/auth/domain/entities/user.dart`).
    - Fields: `id` (String/BigInt), `email` (String).
    - Note: Password hash is handled by backend.
  - [x] Repository Contract: `AuthRepository` (`lib/features/auth/domain/repositories/auth_repository.dart`).
    - Methods: `login(email, password)`, `register(email, password)`, `logout()`.
    - Return: `Future<Either<Failure, User>>`.
  - [x] UseCase: `LoginUser` (`lib/features/auth/domain/usecases/login_user.dart`).
  - [x] UseCase: `RegisterUser` (`lib/features/auth/domain/usecases/register_user.dart`).
  - [x] Unit Tests for UseCases.

- [x] **Data Layer**
  - [x] Model: `UserModel` (extends `User`) (`lib/features/auth/data/models/user_model.dart`).
    - `fromJson`/`toJson`.
    - Maps from Backend DTO: `id_uzytkownika` -> `id`, `email` -> `email`.
  - [x] DataSource: `AuthRemoteDataSource` (Login/Register API calls).
    - Endpoints: `POST /auth/login`, `POST /auth/register`.
  - [x] DataSource: `AuthLocalDataSource` (Token storage).
    - Store JWT token securely. Use `flutter_secure_storage`.
  - [x] Repository Impl: `AuthRepositoryImpl`.
  - [x] Unit Tests for Model and Repository.

- [x] **Presentation Layer**
  - [x] Bloc: `AuthBloc` (Events: Login, Register, Logout).
  - [x] States: `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthError`.
  - [x] Screen: `LoginScreen`.
  - [x] Screen: `RegisterScreen`.
  - [x] Widget: `AuthTextField`, `AuthButton`.
  - [x] Bloc Tests.

- [x] **Set up mock backend**
  - [x] Create mock backend using `node.js` or similar.
  - [x] Define basic endpoints for authentication.
  - [x] Seed with test user data.
