import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/station.dart';
import '../repositories/map_repository.dart';

/// Retrieves all bike stations.
@lazySingleton
class GetStations implements UseCase<List<Station>, NoParams> {
  final MapRepository repository;

  GetStations(this.repository);

  @override
  FutureEither<List<Station>> call(NoParams params) async {
    return await repository.getStations();
  }
}
