import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';

abstract interface class NoteRecognitionRepository {
  Either<Failure, Note> recognizeNote(int midiNumber);
}
