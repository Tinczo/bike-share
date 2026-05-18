import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/base_url_provider.dart';
import '../../../../core/error/exceptions.dart';
import '../../../options/domain/entities/api_options.dart';
import '../models/bike_model.dart';
import '../models/station_model.dart';

/// Remote data source for map-related operations.
abstract class MapRemoteDataSource {
  /// Retrieves bikes near a specific location.
  ///
  /// Throws [ServerException] on server error.
  Future<List<BikeModel>> getNearbyBikes({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  /// Retrieves all bike stations.
  ///
  /// Throws [ServerException] on server error.
  Future<List<StationModel>> getStations();
}

@LazySingleton(as: MapRemoteDataSource)
class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final Dio dio;
  final BaseUrlProvider baseUrlProvider;

  MapRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrlProvider,
  });

  String get _baseUrl => baseUrlProvider.getBaseUrlSync(DataSourceType.map);

  @override
  Future<List<BikeModel>> getNearbyBikes({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final response = await dio.get(
        '$_baseUrl/map/bikes',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radiusKm,
        },
      );

      if (response.statusCode == 200) {
        final bikesJson = response.data['bikes'] as List<dynamic>;
        return bikesJson
            .map((json) => BikeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<List<StationModel>> getStations() async {
    try {
      final response = await dio.get('$_baseUrl/map/stations');

      if (response.statusCode == 200) {
        final stationsJson = response.data['stations'] as List<dynamic>;
        return stationsJson
            .map((json) => StationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }
}
