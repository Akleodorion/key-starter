import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/session/domain/repositories/session_repository.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';

class GetLastSessionParamsUseCase {
  final SessionRepository repository;

  const GetLastSessionParamsUseCase({required this.repository});

  Future<Either<Failure, CreateSessionParams?>> call() {
    return repository.getLastSessionParams();
  }
}
