import 'package:equatable/equatable.dart';

/// Type of wallet transaction.
enum TransactionType {
  /// Top-up (adding funds to wallet).
  topUp,

  /// Fee charged for service usage.
  fee,

  /// Reward or bonus credit.
  reward,

  /// Penalty charge (e.g., for violations).
  penalty,
}

/// Represents a wallet transaction.
///
/// Transactions record all financial activity on the wallet including
/// top-ups, fees, rewards, and penalties.
class Transaction extends Equatable {
  /// Unique identifier for the transaction.
  final String id;

  /// Amount of the transaction in PLN.
  /// Positive for credits, negative for debits.
  final double amount;

  /// Type of transaction.
  final TransactionType type;

  /// Date and time when the transaction occurred.
  final DateTime date;

  /// Human-readable description of the transaction.
  final String description;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
  });

  @override
  List<Object?> get props => [id, amount, type, date, description];
}
