import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/domain/usecases/complete_session_usecase.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';

abstract interface class SessionRepository {
  Future<Either<Failure, Session>> createSession(CreateSessionParams params);
  Either<Failure, Session> completeSession(CompleteSessionParams params);
  Future<Either<Failure, CreateSessionParams?>> getLastSessionParams();
}
