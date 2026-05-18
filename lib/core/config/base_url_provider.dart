import 'package:injectable/injectable.dart';

import '../../features/options/domain/entities/api_options.dart';
import '../../features/options/domain/repositories/options_repository.dart';

/// Provides base URLs for data sources based on user configuration.
@lazySingleton
class BaseUrlProvider {
  final OptionsRepository _optionsRepository;

  /// Cached options to avoid repeated async calls during a session.
  ApiOptions? _cachedOptions;

  BaseUrlProvider(this._optionsRepository);

  /// Gets the base URL for the specified data source type.
  ///
  /// Returns the configured URL or the default if not configured.
  Future<String> getBaseUrl(DataSourceType type) async {
    if (_cachedOptions == null) {
      await _refreshCache();
    }
    return _cachedOptions!.getBaseUrlFor(type);
  }

  /// Gets the base URL synchronously using cached options.
  ///
  /// Returns [defaultBaseUrl] if cache is not initialized.
  /// Prefer using [getBaseUrl] for guaranteed accuracy.
  String getBaseUrlSync(DataSourceType type) {
    return _cachedOptions?.getBaseUrlFor(type) ?? defaultBaseUrl;
  }

  /// Refreshes the cached options from storage.
  ///
  /// Call this after saving new options to ensure data sources
  /// pick up the new configuration.
  Future<void> refreshCache() async {
    await _refreshCache();
  }

  /// Clears the cached options, forcing a reload on next access.
  void clearCache() {
    _cachedOptions = null;
  }

  Future<void> _refreshCache() async {
    final result = await _optionsRepository.getApiOptions();
    result.fold(
      (_) => _cachedOptions = const ApiOptions.defaults(),
      (options) => _cachedOptions = options,
    );
  }
}
