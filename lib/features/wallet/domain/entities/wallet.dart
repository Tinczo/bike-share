import 'package:equatable/equatable.dart';

/// Status of a user's wallet account.
enum WalletStatus {
  /// Wallet is active and can be used for transactions.
  active,

  /// Wallet has negative balance (debt).
  debt,

  /// Wallet is inactive and cannot be used.
  inactive,
}

/// Represents a user's wallet in the system.
///
/// The wallet tracks the user's balance, status, and whether they have
/// a payment card linked for top-ups.
class Wallet extends Equatable {
  /// Current balance in PLN.
  final double balance;

  /// Current status of the wallet.
  final WalletStatus status;

  /// Whether the user has a payment card linked.
  final bool hasCard;

  const Wallet({
    required this.balance,
    required this.status,
    required this.hasCard,
  });

  /// Creates a copy of this wallet with the given fields replaced.
  Wallet copyWith({double? balance, WalletStatus? status, bool? hasCard}) {
    return Wallet(
      balance: balance ?? this.balance,
      status: status ?? this.status,
      hasCard: hasCard ?? this.hasCard,
    );
  }

  @override
  List<Object?> get props => [balance, status, hasCard];
}
