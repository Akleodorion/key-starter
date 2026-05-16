import 'package:equatable/equatable.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';

sealed class NoteRecognitionState extends Equatable {
  const NoteRecognitionState();
}

class NoteRecognitionInitial extends NoteRecognitionState {
  const NoteRecognitionInitial();

  @override
  List<Object?> get props => [];
}

class NoteRecognitionLoaded extends NoteRecognitionState {
  final Note note;

  const NoteRecognitionLoaded({required this.note});

  @override
  List<Object?> get props => [note];
}

class NoteRecognitionError extends NoteRecognitionState {
  final Failure failure;

  const NoteRecognitionError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
