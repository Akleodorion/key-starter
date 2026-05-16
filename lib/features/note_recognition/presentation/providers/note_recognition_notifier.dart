import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_recognition_provider.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_recognition_state.dart';

class NoteRecognitionNotifier extends Notifier<NoteRecognitionState> {
  @override
  NoteRecognitionState build() => const NoteRecognitionInitial();

  void onMidiNoteReceived(int midiNumber) {
    final useCase = ref.read(recognizeNoteUseCaseProvider);
    final result = useCase(midiNumber);
    result.fold(
      (failure) => state = NoteRecognitionError(failure: failure),
      (note) => state = NoteRecognitionLoaded(note: note),
    );
  }
}
