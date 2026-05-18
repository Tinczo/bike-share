import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LogoutUser implements UseCase<Unit, NoParams> {
  final AuthRepository repository;

  LogoutUser(this.repository);

  @override
  FutureEither<Unit> call(NoParams params) async {
    return await repository.logout();
  }
}
