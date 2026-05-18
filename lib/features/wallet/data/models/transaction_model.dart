import '../../domain/entities/transaction.dart';

/// Data model for [Transaction] entity.
///
/// Handles JSON serialization/deserialization with backend field mapping.
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.date,
    required super.description,
  });

  /// Creates a [TransactionModel] from a JSON map.
  ///
  /// Supports both Polish backend format ('id_transakcji', 'kwota', 'typ',
  /// 'czas_rejestracji', 'opis') and English format.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id_transakcji'] ?? json['id']) as String,
      amount: _parseDouble(json['kwota'] ?? json['amount']),
      type: _parseType(json['typ'] ?? json['type'] as String?),
      date: DateTime.parse(
        (json['czas_rejestracji'] ?? json['date']) as String,
      ),
      description: (json['opis'] ?? json['description']) as String,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': _typeToString(type),
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }
    return (value as num).toDouble();
  }

  static TransactionType _parseType(String? type) {
    return switch (type?.toUpperCase()) {
      'TOP_UP' => TransactionType.topUp,
      'FEE' => TransactionType.fee,
      'REWARD' => TransactionType.reward,
      'PENALTY' => TransactionType.penalty,
      _ => TransactionType.topUp,
    };
  }

  static String _typeToString(TransactionType type) {
    return switch (type) {
      TransactionType.topUp => 'TOP_UP',
      TransactionType.fee => 'FEE',
      TransactionType.reward => 'REWARD',
      TransactionType.penalty => 'PENALTY',
    };
  }
}
