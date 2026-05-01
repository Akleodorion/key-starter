import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';
import 'package:key_starter/features/session/domain/usecases/get_last_session_params_usecase.dart';
import 'package:key_starter/features/session/presentation/providers/session_setup_state.dart';
import 'package:key_starter/injection_container.dart';

final _createSessionUseCaseProvider =
    Provider<CreateSessionUseCase>((_) => sl<CreateSessionUseCase>());

final _getLastSessionParamsUseCaseProvider =
    Provider<GetLastSessionParamsUseCase>((_) => sl<GetLastSessionParamsUseCase>());

final sessionSetupNotifierProvider =
    NotifierProvider<SessionSetupNotifier, SessionSetupState>(
  SessionSetupNotifier.new,
);

class SessionSetupNotifier extends Notifier<SessionSetupState> {
  static const _defaultMinTreble = 2;
  static const _defaultMaxTreble = 10;
  static const _defaultMinBass = -10;
  static const _defaultMaxBass = -2;

  static const _semitones = [0, 2, 4, 5, 7, 9, 11];
  static const _names = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

  @override
  SessionSetupState build() {
    _loadLastParams();
    return const SessionSetupInitial();
  }

  Future<void> _loadLastParams() async {
    final result = await ref.read(_getLastSessionParamsUseCaseProvider).call();
    result.fold(
      (_) => state = const SessionSetupLoaded(
        clef: ClefMode.treble,
        minStep: _defaultMinTreble,
        maxStep: _defaultMaxTreble,
        totalNotes: 20,
      ),
      (params) {
        if (params == null) {
          state = const SessionSetupLoaded(
            clef: ClefMode.treble,
            minStep: _defaultMinTreble,
            maxStep: _defaultMaxTreble,
            totalNotes: 20,
          );
        } else {
          state = SessionSetupLoaded(
            clef: params.clef,
            minStep: _noteToStep(params.minNote),
            maxStep: _noteToStep(params.maxNote),
            totalNotes: params.totalNotes,
            noteLanguage: params.showNoteName ? params.language : null,
          );
        }
      },
    );
  }

  void setClef(ClefMode clef) {
    final s = state;
    if (s is! SessionSetupLoaded) return;
    state = SessionSetupLoaded(
      clef: clef,
      minStep: clef == ClefMode.treble ? _defaultMinTreble : _defaultMinBass,
      maxStep: clef == ClefMode.treble ? _defaultMaxTreble : _defaultMaxBass,
      totalNotes: s.totalNotes,
      noteLanguage: s.noteLanguage,
    );
  }

  void setMinStep(int step) {
    final s = state;
    if (s is! SessionSetupLoaded) return;
    state = s.copyWith(minStep: step);
  }

  void setMaxStep(int step) {
    final s = state;
    if (s is! SessionSetupLoaded) return;
    state = s.copyWith(maxStep: step);
  }

  void setTotalNotes(int n) {
    final s = state;
    if (s is! SessionSetupLoaded) return;
    state = s.copyWith(totalNotes: n);
  }

  void setNoteLanguage(NoteLanguage? lang) {
    final s = state;
    if (s is! SessionSetupLoaded) return;
    state = s.copyWith(noteLanguage: () => lang);
  }

  Future<void> startSession() async {
    final s = state;
    if (s is! SessionSetupLoaded) return;
    state = const SessionSetupLoading();

    final params = CreateSessionParams(
      clef: s.clef,
      minNote: _stepToNote(s.minStep),
      maxNote: _stepToNote(s.maxStep),
      totalNotes: s.totalNotes,
      showNoteName: s.noteLanguage != null,
      language: s.noteLanguage ?? NoteLanguage.fr,
    );

    final result = await ref.read(_createSessionUseCaseProvider).call(params);
    result.fold(
      (failure) => state = SessionSetupError(failure.toString()),
      (session) => state = SessionSetupCreated(session),
    );
  }

  Note _stepToNote(int step) {
    final noteIndex = ((step % 7) + 7) % 7;
    final octave = 4 + (step - noteIndex) ~/ 7;
    return Note(
      midiNumber: (octave + 1) * 12 + _semitones[noteIndex],
      name: _names[noteIndex],
      octave: octave,
    );
  }

  int _noteToStep(Note note) {
    final noteIndex = _names.indexOf(note.name);
    if (noteIndex == -1) return 0;
    return (note.octave - 4) * 7 + noteIndex;
  }
}
