import '../../../../core/type_defs.dart';
import '../entities/number_trivia.dart';

abstract class NumberTriviaRepository {
  FutureEither<NumberTrivia> getConcreteNumberTrivia(int number);
  FutureEither<NumberTrivia> getRandomNumberTrivia();
}
