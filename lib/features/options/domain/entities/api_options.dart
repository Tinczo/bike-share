import 'package:equatable/equatable.dart';

/// Enum representing different data source types for URL configuration.
enum DataSourceType {
  auth,
  map,
  rental,
  wallet,
  account,
}

/// Default base URL used when no custom configuration is set.
const String defaultBaseUrl = 'http://10.0.2.2:3000/api';

/// Entity representing API configuration options.
///
/// Contains base URLs for each data source, with support for
/// a unified URL when [sameForAll] is true.
class ApiOptions extends Equatable {
  /// Whether to use the same URL for all data sources.
  final bool sameForAll;

  /// The global base URL used when [sameForAll] is true.
  final String globalBaseUrl;

  /// Base URL for authentication API.
  final String authBaseUrl;

  /// Base URL for map API.
  final String mapBaseUrl;

  /// Base URL for rental API.
  final String rentalBaseUrl;

  /// Base URL for wallet API.
  final String walletBaseUrl;

  /// Base URL for account API.
  final String accountBaseUrl;

  const ApiOptions({
    required this.sameForAll,
    required this.globalBaseUrl,
    required this.authBaseUrl,
    required this.mapBaseUrl,
    required this.rentalBaseUrl,
    required this.walletBaseUrl,
    required this.accountBaseUrl,
  });

  /// Creates default options with all URLs set to [defaultBaseUrl].
  const ApiOptions.defaults()
      : sameForAll = true,
        globalBaseUrl = defaultBaseUrl,
        authBaseUrl = defaultBaseUrl,
        mapBaseUrl = defaultBaseUrl,
        rentalBaseUrl = defaultBaseUrl,
        walletBaseUrl = defaultBaseUrl,
        accountBaseUrl = defaultBaseUrl;

  /// Returns the base URL for the specified [type].
  ///
  /// If [sameForAll] is true, returns [globalBaseUrl].
  /// Otherwise, returns the specific URL for the data source type.
  String getBaseUrlFor(DataSourceType type) {
    if (sameForAll) {
      return globalBaseUrl;
    }

    switch (type) {
      case DataSourceType.auth:
        return authBaseUrl;
      case DataSourceType.map:
        return mapBaseUrl;
      case DataSourceType.rental:
        return rentalBaseUrl;
      case DataSourceType.wallet:
        return walletBaseUrl;
      case DataSourceType.account:
        return accountBaseUrl;
    }
  }

  /// Creates a copy with the specified fields replaced.
  ApiOptions copyWith({
    bool? sameForAll,
    String? globalBaseUrl,
    String? authBaseUrl,
    String? mapBaseUrl,
    String? rentalBaseUrl,
    String? walletBaseUrl,
    String? accountBaseUrl,
  }) {
    return ApiOptions(
      sameForAll: sameForAll ?? this.sameForAll,
      globalBaseUrl: globalBaseUrl ?? this.globalBaseUrl,
      authBaseUrl: authBaseUrl ?? this.authBaseUrl,
      mapBaseUrl: mapBaseUrl ?? this.mapBaseUrl,
      rentalBaseUrl: rentalBaseUrl ?? this.rentalBaseUrl,
      walletBaseUrl: walletBaseUrl ?? this.walletBaseUrl,
      accountBaseUrl: accountBaseUrl ?? this.accountBaseUrl,
    );
  }

  @override
  List<Object?> get props => [
        sameForAll,
        globalBaseUrl,
        authBaseUrl,
        mapBaseUrl,
        rentalBaseUrl,
        walletBaseUrl,
        accountBaseUrl,
      ];
}
