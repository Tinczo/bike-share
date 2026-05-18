import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/api_options_model.dart';

/// Key for storing API options in SharedPreferences.
const String apiOptionsKey = 'API_OPTIONS';

/// Local data source for API options persistence.
abstract class OptionsLocalDataSource {
  /// Retrieves the stored API options.
  ///
  /// Returns [ApiOptionsModel.defaults] if no options are stored.
  Future<ApiOptionsModel> getApiOptions();

  /// Saves the API options to persistent storage.
  Future<void> saveApiOptions(ApiOptionsModel options);
}

@LazySingleton(as: OptionsLocalDataSource)
class OptionsLocalDataSourceImpl implements OptionsLocalDataSource {
  final SharedPreferences sharedPreferences;

  OptionsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ApiOptionsModel> getApiOptions() async {
    final jsonString = sharedPreferences.getString(apiOptionsKey);

    if (jsonString == null) {
      return const ApiOptionsModel.defaults();
    }

    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return ApiOptionsModel.fromJson(jsonMap);
  }

  @override
  Future<void> saveApiOptions(ApiOptionsModel options) async {
    final jsonString = json.encode(options.toJson());
    await sharedPreferences.setString(apiOptionsKey, jsonString);
  }
}
