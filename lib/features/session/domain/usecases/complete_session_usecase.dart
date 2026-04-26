import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/domain/entities/session_result.dart';
import 'package:key_starter/features/session/domain/repositories/session_repository.dart';

class CompleteSessionParams extends Equatable {
  final Session session;
  final SessionResult result;

  const CompleteSessionParams({required this.session, required this.result});

  @override
  List<Object?> get props => [session, result];
}

class CompleteSessionUseCase {
  final SessionRepository repository;

  const CompleteSessionUseCase({required this.repository});

  Either<Failure, Session> call(CompleteSessionParams params) {
    return repository.completeSession(params);
  }
}
