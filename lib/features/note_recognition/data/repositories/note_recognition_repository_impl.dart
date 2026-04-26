import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/data/datasources/midi_datasource.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/note_recognition/domain/repositories/note_recognition_repository.dart';

class NoteRecognitionRepositoryImpl implements NoteRecognitionRepository {
  final MidiDataSource dataSource;

  const NoteRecognitionRepositoryImpl({required this.dataSource});

  @override
  Either<Failure, Note> recognizeNote(int midiNumber) {
    try {
      final note = dataSource.noteFromMidiNumber(midiNumber);
      return Right(note);
    } on MidiException catch (e) {
      return Left(InvalidMidiNoteFailure(e.midiNumber));
    }
  }
}
