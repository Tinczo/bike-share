import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/type_defs.dart';
import '../../domain/entities/fault_report.dart';
import '../../domain/entities/fault_type.dart';
import '../../domain/entities/rental_history_item.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

@LazySingleton(as: AccountRepository)
class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AccountRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  FutureEither<List<RentalHistoryItem>> getRentalHistory() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final rentalHistory = await remoteDataSource.getRentalHistory();
      return Right(rentalHistory);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<List<FaultReport>> getFaultReportHistory() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final faultReports = await remoteDataSource.getFaultReportHistory();
      return Right(faultReports);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  FutureEither<FaultReport> reportFault({
    required String bikeId,
    required FaultType type,
    String? description,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final faultReport = await remoteDataSource.reportFault(
        bikeId: bikeId,
        type: type,
        description: description,
      );
      return Right(faultReport);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
