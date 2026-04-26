import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/session/data/datasources/session_local_datasource.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/domain/repositories/session_repository.dart';
import 'package:key_starter/features/session/domain/usecases/complete_session_usecase.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';
import 'package:uuid/uuid.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionLocalDataSource dataSource;
  final String Function() generateId;
  final DateTime Function() now;

  SessionRepositoryImpl({
    required this.dataSource,
    String Function()? generateId,
    DateTime Function()? now,
  })  : generateId = generateId ?? (() => const Uuid().v4()),
        now = now ?? DateTime.now;

  @override
  Future<Either<Failure, Session>> createSession(CreateSessionParams params) async {
    if (params.totalNotes < 5 || params.totalNotes > 100) {
      return const Left(InvalidSessionParamsFailure());
    }
    if (params.minNote.midiNumber >= params.maxNote.midiNumber) {
      return const Left(InvalidSessionParamsFailure());
    }
    try {
      await dataSource.saveLastParams(params);
      return Right(Session(
        id: generateId(),
        clef: params.clef,
        minNote: params.minNote,
        maxNote: params.maxNote,
        totalNotes: params.totalNotes,
        showNoteName: params.showNoteName,
        language: params.language,
        startedAt: now(),
      ));
    } on SharedPreferencesException {
      return const Left(CacheFailure());
    }
  }

  @override
  Either<Failure, Session> completeSession(CompleteSessionParams params) {
    if (params.session.isCompleted) {
      return const Left(SessionAlreadyCompletedFailure());
    }
    return Right(params.session.copyWith(result: params.result));
  }

  @override
  Future<Either<Failure, CreateSessionParams?>> getLastSessionParams() async {
    try {
      return Right(await dataSource.getLastParams());
    } on SharedPreferencesException {
      return const Left(CacheFailure());
    }
  }
}
