import 'package:dartz/dartz.dart';

import '../../../../core/type_defs.dart';
import '../entities/user.dart';

/// Contract for authentication operations.
///
/// This interface defines all authentication-related operations that must be
/// implemented by the data layer.
abstract class AuthRepository {
  /// Authenticates a user with email and password.
  ///
  /// Returns [User] on success or [Failure] on error.
  FutureEither<User> login({required String email, required String password});

  /// Registers a new user with email and password.
  ///
  /// Returns [User] on success or [Failure] on error.
  FutureEither<User> register({
    required String email,
    required String password,
  });

  /// Logs out the current user.
  ///
  /// Returns [Unit] on success or [Failure] on error.
  FutureEither<Unit> logout();

  /// Retrieves the currently authenticated user.
  ///
  /// Returns [User] if authenticated, null if not, or [Failure] on error.
  FutureEither<User?> getCurrentUser();
}
