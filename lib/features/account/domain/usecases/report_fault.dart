import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fault_report.dart';
import '../entities/fault_type.dart';
import '../repositories/account_repository.dart';

/// Use case for reporting a fault on a bike.
@lazySingleton
class ReportFault implements UseCase<FaultReport, ReportFaultParams> {
  final AccountRepository repository;

  ReportFault(this.repository);

  @override
  FutureEither<FaultReport> call(ReportFaultParams params) async {
    return await repository.reportFault(
      bikeId: params.bikeId,
      type: params.type,
      description: params.description,
    );
  }
}

/// Parameters for [ReportFault] use case.
class ReportFaultParams extends Equatable {
  /// ID of the bike with the fault.
  final String bikeId;

  /// Type of fault being reported.
  final FaultType type;

  /// Optional description for the fault.
  final String? description;

  const ReportFaultParams({
    required this.bikeId,
    required this.type,
    this.description,
  });

  @override
  List<Object?> get props => [bikeId, type, description];
}
