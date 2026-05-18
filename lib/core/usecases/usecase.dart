import 'package:equatable/equatable.dart';

import '../type_defs.dart';

abstract class UseCase<T, Params> {
  FutureEither<T> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
