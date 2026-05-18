import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/api_options.dart';
import '../../domain/repositories/options_repository.dart';
import '../datasources/options_local_datasource.dart';
import '../models/api_options_model.dart';

@LazySingleton(as: OptionsRepository)
class OptionsRepositoryImpl implements OptionsRepository {
  final OptionsLocalDataSource localDataSource;

  OptionsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ApiOptions>> getApiOptions() async {
    try {
      final options = await localDataSource.getApiOptions();
      return Right(options);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveApiOptions(ApiOptions options) async {
    try {
      final model = ApiOptionsModel.fromEntity(options);
      await localDataSource.saveApiOptions(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
