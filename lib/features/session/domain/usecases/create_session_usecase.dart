import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/domain/repositories/session_repository.dart';

class CreateSessionParams extends Equatable {
  final ClefMode clef;
  final Note minNote;
  final Note maxNote;
  final int totalNotes;
  final bool showNoteName;
  final NoteLanguage language;

  const CreateSessionParams({
    required this.clef,
    required this.minNote,
    required this.maxNote,
    required this.totalNotes,
    required this.showNoteName,
    required this.language,
  });

  @override
  List<Object?> get props => [clef, minNote, maxNote, totalNotes, showNoteName, language];
}

class CreateSessionUseCase {
  final SessionRepository repository;

  const CreateSessionUseCase({required this.repository});

  Future<Either<Failure, Session>> call(CreateSessionParams params) {
    return repository.createSession(params);
  }
}
