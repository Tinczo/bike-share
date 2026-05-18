import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUser implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  FutureEither<User> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;

  const RegisterParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
