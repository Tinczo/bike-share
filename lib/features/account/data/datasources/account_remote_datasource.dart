import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/base_url_provider.dart';
import '../../../../core/error/exceptions.dart';
import '../../../options/domain/entities/api_options.dart';
import '../../domain/entities/fault_type.dart';
import '../models/fault_report_model.dart';
import '../models/rental_history_item_model.dart';

/// Remote data source for account-related operations.
abstract class AccountRemoteDataSource {
  /// Gets the user's rental history.
  ///
  /// Throws [ServerException] on server error.
  Future<List<RentalHistoryItemModel>> getRentalHistory();

  /// Gets the user's fault report history.
  ///
  /// Throws [ServerException] on server error.
  Future<List<FaultReportModel>> getFaultReportHistory();

  /// Reports a fault for a bike.
  ///
  /// Throws [ServerException] on server error.
  Future<FaultReportModel> reportFault({
    required String bikeId,
    required FaultType type,
    String? description,
  });
}

@LazySingleton(as: AccountRemoteDataSource)
class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final Dio dio;
  final BaseUrlProvider baseUrlProvider;

  AccountRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrlProvider,
  });

  String get _baseUrl =>
      baseUrlProvider.getBaseUrlSync(DataSourceType.account);

  @override
  Future<List<RentalHistoryItemModel>> getRentalHistory() async {
    try {
      final response = await dio.get('$_baseUrl/history/rentals');

      if (response.statusCode == 200) {
        final List<dynamic> rentalsJson =
            (response.data['rentals'] ?? response.data) as List<dynamic>;

        return rentalsJson
            .map(
              (json) =>
                  RentalHistoryItemModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<List<FaultReportModel>> getFaultReportHistory() async {
    try {
      final response = await dio.get('$_baseUrl/history/faults');

      if (response.statusCode == 200) {
        final List<dynamic> faultsJson =
            (response.data['faults'] ?? response.data) as List<dynamic>;

        return faultsJson
            .map(
              (json) => FaultReportModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<FaultReportModel> reportFault({
    required String bikeId,
    required FaultType type,
    String? description,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/faults/report',
        data: {
          'bikeId': bikeId,
          'type': type.apiValue,
          'description': description,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['fault'] as Map<String, dynamic>?;
        if (data != null) {
          return FaultReportModel.fromJson(data);
        }
        return FaultReportModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }
}
