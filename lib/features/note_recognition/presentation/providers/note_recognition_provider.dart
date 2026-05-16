import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/note_recognition/domain/usecases/recognize_note_usecase.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_recognition_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_recognition_state.dart';
import 'package:key_starter/injection_container.dart';

// Declared here (not in notifier) to avoid circular imports.
final recognizeNoteUseCaseProvider = Provider<RecognizeNoteUseCase>(
  (_) => sl<RecognizeNoteUseCase>(),
);

final noteRecognitionProvider =
    NotifierProvider<NoteRecognitionNotifier, NoteRecognitionState>(
  NoteRecognitionNotifier.new,
);
