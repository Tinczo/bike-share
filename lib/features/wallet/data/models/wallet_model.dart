import '../../domain/entities/wallet.dart';

/// Data model for [Wallet] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class WalletModel extends Wallet {
  const WalletModel({
    required super.balance,
    required super.status,
    required super.hasCard,
  });

  /// Creates a [WalletModel] from a JSON map.
  ///
  /// Supports both Polish backend format ('saldo', 'ma_podpieta_karte')
  /// and English format ('balance', 'hasCard').
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: _parseDouble(json['saldo'] ?? json['balance']),
      status: _parseStatus(json['status'] as String?),
      hasCard: (json['ma_podpieta_karte'] ?? json['hasCard'] ?? false) as bool,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'status': _statusToString(status),
      'hasCard': hasCard,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }
    return (value as num).toDouble();
  }

  static WalletStatus _parseStatus(String? status) {
    return switch (status?.toUpperCase()) {
      'ACTIVE' => WalletStatus.active,
      'DEBT' => WalletStatus.debt,
      'INACTIVE' => WalletStatus.inactive,
      _ => WalletStatus.active,
    };
  }

  static String _statusToString(WalletStatus status) {
    return switch (status) {
      WalletStatus.active => 'ACTIVE',
      WalletStatus.debt => 'DEBT',
      WalletStatus.inactive => 'INACTIVE',
    };
  }
}
