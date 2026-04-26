import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/note_recognition/domain/repositories/note_recognition_repository.dart';

class RecognizeNoteUseCase {
  final NoteRecognitionRepository repository;

  const RecognizeNoteUseCase({required this.repository});

  Either<Failure, Note> call(int midiNumber) {
    return repository.recognizeNote(midiNumber);
  }
}
