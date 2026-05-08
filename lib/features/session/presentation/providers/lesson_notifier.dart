import 'dart:async';
import 'dart:math';

import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/domain/entities/session_result.dart';
import 'package:key_starter/features/session/domain/usecases/complete_session_usecase.dart';
import 'package:key_starter/features/session/presentation/providers/lesson_state.dart';
import 'package:key_starter/injection_container.dart';

final _completeSessionUseCaseProvider =
    Provider<CompleteSessionUseCase>((_) => sl<CompleteSessionUseCase>());

final lessonNotifierProvider = NotifierProvider.autoDispose
    .family<LessonNotifier, LessonState, Session>(
      (arg) => LessonNotifier(arg),
    );

class LessonNotifier extends Notifier<LessonState> {
  final Session _session;
  final _random = Random();
  final List<int> _responseTimes = [];
  int _currentStreak = 0;
  int _bestStreak = 0;
  DateTime? _noteShownAt;

  LessonNotifier(this._session);

  @override
  LessonState build() {
    _noteShownAt = DateTime.now();

    final midiSub = MidiCommand().onMidiDataReceived?.listen((packet) {
      if (packet.data.length >= 3 &&
          (packet.data[0] & 0xF0) == 0x90 &&
          packet.data[2] > 0) {
        final current = state;
        if (current is! LessonInProgress) return;
        if (packet.data[1] == _stepToMidi(current.currentStep)) {
          onCorrect();
        } else {
          onWrong();
        }
      }
    });
    ref.onDispose(() => midiSub?.cancel());

    return LessonInProgress(
      session: _session,
      currentStep: _pickStep(),
      currentIndex: 0,
    );
  }

  void onCorrect() {
    final current = state;
    if (current is! LessonInProgress) return;
    if (current.answer != LessonAnswer.awaiting) return;

    if (_noteShownAt != null) {
      _responseTimes
          .add(DateTime.now().difference(_noteShownAt!).inMilliseconds);
    }
    _currentStreak++;
    if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;

    state = current.copyWith(
      answer: LessonAnswer.correct,
      correctCount: current.correctCount + 1,
    );
    Future.delayed(const Duration(milliseconds: 25), _advance);
  }

  void onWrong() {
    final current = state;
    if (current is! LessonInProgress) return;
    if (current.answer != LessonAnswer.awaiting) return;

    if (_noteShownAt != null) {
      _responseTimes
          .add(DateTime.now().difference(_noteShownAt!).inMilliseconds);
    }
    _currentStreak = 0;

    state = current.copyWith(answer: LessonAnswer.wrong);
    Future.delayed(const Duration(milliseconds: 25), _advance);
  }

  void _advance() {
    final current = state;
    if (current is! LessonInProgress) return;

    final nextIndex = current.currentIndex + 1;
    if (nextIndex >= current.session.totalNotes) {
      _endSession(current);
      return;
    }

    _noteShownAt = DateTime.now();
    state = current.copyWith(
      currentIndex: nextIndex,
      answer: LessonAnswer.awaiting,
      currentStep: _pickStep(),
    );
  }

  void _endSession(LessonInProgress current) {
    final avgMs = _responseTimes.isEmpty
        ? 0
        : _responseTimes.reduce((a, b) => a + b) ~/ _responseTimes.length;

    final result = SessionResult(
      correctCount: current.correctCount,
      totalNotes: current.session.totalNotes,
      durationSec:
          DateTime.now().difference(current.session.startedAt).inSeconds,
      bestStreak: _bestStreak,
      avgResponseMs: avgMs,
    );

    ref.read(_completeSessionUseCaseProvider)(
      CompleteSessionParams(session: current.session, result: result),
    ).fold(
      (_) => state = LessonCompleted(completedSession: current.session),
      (completed) => state = LessonCompleted(completedSession: completed),
    );
  }

  int _noteToStep(Note note) {
    final i = noteNamesEn.indexOf(note.name);
    return (note.octave - 4) * 7 + (i == -1 ? 0 : i);
  }

  int _pickStep() {
    final min = _noteToStep(_session.minNote);
    final max = _noteToStep(_session.maxNote);
    return min + _random.nextInt(max - min + 1);
  }

  int _stepToMidi(int step) {
    final noteIndex = ((step % 7) + 7) % 7;
    final octave = 4 + (step - noteIndex) ~/ 7;
    return (octave + 1) * 12 + diatonicSemitones[noteIndex];
  }
}
