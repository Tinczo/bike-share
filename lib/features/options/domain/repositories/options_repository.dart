import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/api_options.dart';

/// Repository contract for API options persistence.
abstract class OptionsRepository {
  /// Retrieves the stored API options.
  ///
  /// Returns [ApiOptions.defaults] if no options are stored.
  Future<Either<Failure, ApiOptions>> getApiOptions();

  /// Saves the API options.
  Future<Either<Failure, void>> saveApiOptions(ApiOptions options);
}
