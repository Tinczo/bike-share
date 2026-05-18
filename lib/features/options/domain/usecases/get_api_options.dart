import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/api_options.dart';
import '../repositories/options_repository.dart';

/// Use case for retrieving API options.
@lazySingleton
class GetApiOptions implements UseCase<ApiOptions, NoParams> {
  final OptionsRepository repository;

  GetApiOptions(this.repository);

  @override
  FutureEither<ApiOptions> call(NoParams params) async {
    return await repository.getApiOptions();
  }
}
