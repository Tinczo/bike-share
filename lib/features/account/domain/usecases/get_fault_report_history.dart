import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fault_report.dart';
import '../repositories/account_repository.dart';

/// Use case for retrieving the user's fault report history.
@lazySingleton
class GetFaultReportHistory implements UseCase<List<FaultReport>, NoParams> {
  final AccountRepository repository;

  GetFaultReportHistory(this.repository);

  @override
  FutureEither<List<FaultReport>> call(NoParams params) async {
    return await repository.getFaultReportHistory();
  }
}
