import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/api_options.dart';
import '../repositories/options_repository.dart';

/// Use case for saving API options.
@lazySingleton
class SaveApiOptions implements UseCase<void, ApiOptions> {
  final OptionsRepository repository;

  SaveApiOptions(this.repository);

  @override
  FutureEither<void> call(ApiOptions params) async {
    return await repository.saveApiOptions(params);
  }
}
