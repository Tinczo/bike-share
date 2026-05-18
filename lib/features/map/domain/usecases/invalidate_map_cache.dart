import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/map_repository.dart';

/// Invalidates the local map data cache.
///
/// This forces subsequent data fetches to retrieve fresh data from network.
@lazySingleton
class InvalidateMapCache implements UseCase<Unit, NoParams> {
  final MapRepository repository;

  InvalidateMapCache(this.repository);

  @override
  FutureEither<Unit> call(NoParams params) async {
    return await repository.invalidateCache();
  }
}
