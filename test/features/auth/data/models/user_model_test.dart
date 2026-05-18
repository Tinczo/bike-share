import 'dart:convert';

import 'package:bike_app/features/auth/data/models/user_model.dart';
import 'package:bike_app/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tUserModel = UserModel(id: '123', email: 'test@example.com');

  test('should be a subclass of User entity', () {
    // assert
    expect(tUserModel, isA<User>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON with id_uzytkownika', () {
      // arrange
      final jsonMap = {'id_uzytkownika': '123', 'email': 'test@example.com'};

      // act
      final result = UserModel.fromJson(jsonMap);

      // assert
      expect(result, tUserModel);
    });

    test('should return a valid model from JSON with id', () {
      // arrange
      final jsonMap = {'id': '123', 'email': 'test@example.com'};

      // act
      final result = UserModel.fromJson(jsonMap);

      // assert
      expect(result, tUserModel);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // act
      final result = tUserModel.toJson();

      // assert
      final expectedMap = {'id': '123', 'email': 'test@example.com'};
      expect(result, expectedMap);
    });
  });

  group('JSON string conversion', () {
    test('should correctly deserialize from JSON string', () {
      // arrange
      const jsonString = '{"id_uzytkownika":"123","email":"test@example.com"}';

      // act
      final result = UserModel.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );

      // assert
      expect(result, tUserModel);
    });

    test('should correctly serialize to JSON string', () {
      // act
      final jsonString = json.encode(tUserModel.toJson());

      // assert
      expect(jsonString, contains('"id":"123"'));
      expect(jsonString, contains('"email":"test@example.com"'));
    });
  });
}
