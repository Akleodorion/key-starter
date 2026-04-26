import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/note_recognition/domain/usecases/recognize_note_usecase.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_recognition_state.dart';
import 'package:key_starter/injection_container.dart';

final recognizeNoteUseCaseProvider = Provider<RecognizeNoteUseCase>(
  (ref) => sl(),
);

class NoteRecognitionNotifier extends Notifier<NoteRecognitionState> {
  @override
  NoteRecognitionState build() => const NoteRecognitionInitial();

  void onMidiNoteReceived(int midiNumber) {
    ref.read(recognizeNoteUseCaseProvider)(midiNumber).fold(
      (failure) => state = NoteRecognitionError(failure: failure),
      (note) => state = NoteRecognitionLoaded(note: note),
    );
  }
}
