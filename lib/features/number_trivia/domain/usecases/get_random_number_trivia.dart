import 'package:injectable/injectable.dart';

import '../../../../core/type_defs.dart';
import '../../../../core/usecases/usecase.dart';
import '../contracts/number_trivia_repository_contract.dart';
import '../entities/number_trivia.dart';

@lazySingleton
class GetRandomNumberTrivia implements UseCase<NumberTrivia, NoParams> {
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);

  @override
  FutureEither<NumberTrivia> call(NoParams params) async {
    return await repository.getRandomNumberTrivia();
  }
}
