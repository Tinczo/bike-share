import 'package:dartz/dartz.dart';

import 'error/failures.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
