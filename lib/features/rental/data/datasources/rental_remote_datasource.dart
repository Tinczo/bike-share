import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/base_url_provider.dart';
import '../../../../core/error/exceptions.dart';
import '../../../options/domain/entities/api_options.dart';
import '../../domain/entities/rental_launch_method.dart';
import '../models/rental_eligibility_model.dart';
import '../models/rental_model.dart';
import '../models/reservation_model.dart';

/// Remote data source for rental operations.
abstract class RentalRemoteDataSource {
  /// Checks if the current user is eligible to rent.
  ///
  /// Throws [ServerException] on server error.
  Future<RentalEligibilityModel> checkEligibility();

  /// Starts a rental for the specified bike.
  ///
  /// Throws [PaymentRequiredException] when balance is insufficient (402).
  /// Throws [BikeUnavailableException] when bike is not available (409).
  /// Throws [IoTTimeoutException] when IoT device fails (504).
  /// Throws [ServerException] on other server errors.
  Future<RentalModel> startRental({
    required String bikeId,
    required RentalLaunchMethod method,
  });

  /// Pauses an active rental.
  ///
  /// Throws [ServerException] on server error.
  Future<RentalModel> pauseRental({required String rentalId});

  /// Resumes a paused rental.
  ///
  /// Throws [ServerException] on server error.
  Future<RentalModel> resumeRental({required String rentalId});

  /// Ends an active rental.
  ///
  /// Throws [ServerException] on server error.
  Future<RentalModel> endRental({required String rentalId});

  /// Gets the current user's active rental.
  ///
  /// Returns null if no active rental exists.
  /// Throws [ServerException] on server error.
  Future<RentalModel?> getActiveRental();

  /// Creates a reservation for the specified bike.
  ///
  /// Throws [PaymentRequiredException] when balance is insufficient (402).
  /// Throws [BikeUnavailableException] when bike is not available (409).
  /// Throws [ServerException] on other server errors.
  Future<ReservationModel> createReservation({required String bikeId});

  /// Cancels an active reservation.
  ///
  /// Throws [ReservationExpiredException] when reservation has expired.
  /// Throws [ServerException] on server error.
  Future<void> cancelReservation({required String reservationId});

  /// Gets the current user's active reservation.
  ///
  /// Returns null if no active reservation exists.
  /// Throws [ServerException] on server error.
  Future<ReservationModel?> getActiveReservation();
}

@LazySingleton(as: RentalRemoteDataSource)
class RentalRemoteDataSourceImpl implements RentalRemoteDataSource {
  final Dio dio;
  final BaseUrlProvider baseUrlProvider;

  RentalRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrlProvider,
  });

  String get _baseUrl => baseUrlProvider.getBaseUrlSync(DataSourceType.rental);

  @override
  Future<RentalEligibilityModel> checkEligibility() async {
    try {
      final response = await dio.get('$_baseUrl/rental/eligibility');

      if (response.statusCode == 200) {
        final data = response.data['eligibility'] as Map<String, dynamic>?;
        if (data != null) {
          return RentalEligibilityModel.fromJson(data);
        }
        return RentalEligibilityModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<RentalModel> startRental({
    required String bikeId,
    required RentalLaunchMethod method,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/rental/start',
        data: {
          'bikeId': bikeId,
          'method': method == RentalLaunchMethod.qr ? 'QR' : 'MANUAL',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['rental'] as Map<String, dynamic>?;
        if (data != null) {
          return RentalModel.fromJson(data);
        }
        return RentalModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException();
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        throw PaymentRequiredException();
      }
      if (e.response?.statusCode == 409) {
        throw BikeUnavailableException();
      }
      if (e.response?.statusCode == 504) {
        throw IoTTimeoutException();
      }
      throw ServerException();
    }
  }

  @override
  Future<RentalModel> pauseRental({required String rentalId}) async {
    try {
      final response = await dio.post('$_baseUrl/rental/$rentalId/pause');

      if (response.statusCode == 200) {
        final data = response.data['rental'] as Map<String, dynamic>?;
        if (data != null) {
          return RentalModel.fromJson(data);
        }
        return RentalModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<RentalModel> resumeRental({required String rentalId}) async {
    try {
      final response = await dio.post('$_baseUrl/rental/$rentalId/resume');

      if (response.statusCode == 200) {
        final data = response.data['rental'] as Map<String, dynamic>?;
        if (data != null) {
          return RentalModel.fromJson(data);
        }
        return RentalModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<RentalModel> endRental({required String rentalId}) async {
    try {
      final response = await dio.post('$_baseUrl/rental/$rentalId/end');

      if (response.statusCode == 200) {
        final data = response.data['rental'] as Map<String, dynamic>?;
        if (data != null) {
          return RentalModel.fromJson(data);
        }
        return RentalModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException();
    } on DioException {
      throw ServerException();
    }
  }

  @override
  Future<RentalModel?> getActiveRental() async {
    try {
      final response = await dio.get('$_baseUrl/rental/active');

      if (response.statusCode == 200) {
        final data = response.data['rental'] as Map<String, dynamic>?;
        if (data == null) {
          return null;
        }
        return RentalModel.fromJson(data);
      }
      if (response.statusCode == 204 || response.statusCode == 404) {
        return null;
      }
      throw ServerException();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ServerException();
    }
  }

  @override
  Future<ReservationModel> createReservation({required String bikeId}) async {
    try {
      final response = await dio.post(
        '$_baseUrl/rental/reservation',
        data: {'bikeId': bikeId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['reservation'] as Map<String, dynamic>?;
        if (data != null) {
          return ReservationModel.fromJson(data);
        }
        return ReservationModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException();
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        throw PaymentRequiredException();
      }
      if (e.response?.statusCode == 409) {
        throw BikeUnavailableException();
      }
      throw ServerException();
    }
  }

  @override
  Future<void> cancelReservation({required String reservationId}) async {
    try {
      final response = await dio.delete(
        '$_baseUrl/rental/reservation/$reservationId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }
      throw ServerException();
    } on DioException catch (e) {
      if (e.response?.statusCode == 410) {
        throw ReservationExpiredException();
      }
      throw ServerException();
    }
  }

  @override
  Future<ReservationModel?> getActiveReservation() async {
    try {
      final response = await dio.get('$_baseUrl/rental/reservation/active');

      if (response.statusCode == 200) {
        final data = response.data['reservation'] as Map<String, dynamic>?;
        if (data == null) {
          return null;
        }
        return ReservationModel.fromJson(data);
      }
      if (response.statusCode == 204 || response.statusCode == 404) {
        return null;
      }
      throw ServerException();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ServerException();
    }
  }
}
