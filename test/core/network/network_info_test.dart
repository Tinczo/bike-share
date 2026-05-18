import 'package:bike_app/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';

class MockInternetConnection extends Mock implements InternetConnection {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnection mockInternetConnection;

  setUp(() {
    mockInternetConnection = MockInternetConnection();
    networkInfo = NetworkInfoImpl(mockInternetConnection);
  });

  group('isConnected', () {
    test(
      'should forward the call to InternetConnection.hasInternetAccess',
      () async {
        // arrange
        when(
          () => mockInternetConnection.hasInternetAccess,
        ).thenAnswer((_) async => true);

        // act
        final result = await networkInfo.isConnected;

        // assert
        verify(() => mockInternetConnection.hasInternetAccess).called(1);
        expect(result, true);
      },
    );

    test('should return false when there is no internet connection', () async {
      // arrange
      when(
        () => mockInternetConnection.hasInternetAccess,
      ).thenAnswer((_) async => false);

      // act
      final result = await networkInfo.isConnected;

      // assert
      verify(() => mockInternetConnection.hasInternetAccess).called(1);
      expect(result, false);
    });
  });
}
