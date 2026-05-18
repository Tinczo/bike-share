import '../../../../core/type_defs.dart';
import '../entities/fault_report.dart';
import '../entities/fault_type.dart';
import '../entities/rental_history_item.dart';

/// Contract for account-related operations.
///
/// This interface defines all account-related operations that must be
/// implemented by the data layer.
abstract class AccountRepository {
  /// Gets the user's rental history.
  ///
  /// Returns a list of [RentalHistoryItem] on success or [Failure] on error.
  FutureEither<List<RentalHistoryItem>> getRentalHistory();

  /// Gets the user's fault report history.
  ///
  /// Returns a list of [FaultReport] on success or [Failure] on error.
  FutureEither<List<FaultReport>> getFaultReportHistory();

  /// Reports a fault for a bike.
  ///
  /// [bikeId] - The ID of the bike with the fault.
  /// [type] - The type of fault being reported.
  /// [description] - Optional description, required for [FaultType.other].
  ///
  /// Returns the created [FaultReport] on success or [Failure] on error.
  FutureEither<FaultReport> reportFault({
    required String bikeId,
    required FaultType type,
    String? description,
  });
}
