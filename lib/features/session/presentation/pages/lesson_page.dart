import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/widgets/staff_widget.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/domain/entities/session_result.dart';
import 'package:key_starter/features/session/domain/usecases/complete_session_usecase.dart';
import 'package:key_starter/features/session/presentation/pages/results_page.dart';
import 'package:key_starter/injection_container.dart';

enum _Answer { none, correct, wrong }

final _completeSessionUseCaseProvider =
    Provider<CompleteSessionUseCase>((_) => sl<CompleteSessionUseCase>());

class LessonPage extends ConsumerStatefulWidget {
  final Session session;

  const LessonPage({super.key, required this.session});

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  static const _namesEn = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
  static const _namesFr = ['Do', 'Ré', 'Mi', 'Fa', 'Sol', 'La', 'Si'];
  static const _semitones = [0, 2, 4, 5, 7, 9, 11];

  final _random = Random();
  final List<int> _responseTimes = [];
  StreamSubscription<MidiPacket>? _midiSub;

  int _currentIndex = 0;
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  _Answer _answer = _Answer.none;
  late int _currentStep;
  DateTime? _noteShownAt;

  int get _total => widget.session.totalNotes;

  @override
  void initState() {
    super.initState();
    _currentStep = _pickStep();
    _midiSub = MidiCommand().onMidiDataReceived?.listen((packet) {
      if (packet.data.length >= 3 &&
          (packet.data[0] & 0xF0) == 0x90 &&
          packet.data[2] > 0) {
        if (packet.data[1] == _stepToMidi(_currentStep)) {
          _onCorrect();
        } else {
          _onWrong();
        }
      }
    });
  }

  @override
  void dispose() {
    _midiSub?.cancel();
    super.dispose();
  }

  int _noteToStep(Note note) {
    final i = _namesEn.indexOf(note.name);
    return (note.octave - 4) * 7 + (i == -1 ? 0 : i);
  }

  int _pickStep() {
    final min = _noteToStep(widget.session.minNote);
    final max = _noteToStep(widget.session.maxNote);
    return min + _random.nextInt(max - min + 1);
  }

  int _stepToMidi(int step) {
    final noteIndex = ((step % 7) + 7) % 7;
    final octave = 4 + (step - noteIndex) ~/ 7;
    return (octave + 1) * 12 + _semitones[noteIndex];
  }

  String _stepToLabel(int step) {
    final noteIndex = ((step % 7) + 7) % 7;
    final octave = 4 + (step - noteIndex) ~/ 7;
    final names = widget.session.language == NoteLanguage.fr ? _namesFr : _namesEn;
    return '${names[noteIndex]} $octave';
  }

  void _onCorrect() {
    if (_answer != _Answer.none) return;
    if (_noteShownAt != null) {
      _responseTimes.add(DateTime.now().difference(_noteShownAt!).inMilliseconds);
    }
    _currentStreak++;
    if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
    setState(() {
      _answer = _Answer.correct;
      _correctCount++;
    });
    Future.delayed(const Duration(milliseconds: 25), _advance);
  }

  void _onWrong() {
    if (_answer != _Answer.none) return;
    if (_noteShownAt != null) {
      _responseTimes.add(DateTime.now().difference(_noteShownAt!).inMilliseconds);
    }
    _currentStreak = 0;
    setState(() => _answer = _Answer.wrong);
    Future.delayed(const Duration(milliseconds: 25), _advance);
  }

  void _advance() {
    if (!mounted) return;
    _currentIndex++;
    if (_currentIndex >= _total) {
      _endSession();
      return;
    }
    setState(() {
      _answer = _Answer.none;
      _currentStep = _pickStep();
      _noteShownAt = DateTime.now();
    });
  }

  void _endSession() {
    final avgMs = _responseTimes.isEmpty
        ? 0
        : _responseTimes.reduce((a, b) => a + b) ~/ _responseTimes.length;

    final result = SessionResult(
      correctCount: _correctCount,
      totalNotes: _total,
      durationSec: DateTime.now().difference(widget.session.startedAt).inSeconds,
      bestStreak: _bestStreak,
      avgResponseMs: avgMs,
    );

    ref.read(_completeSessionUseCaseProvider)(
      CompleteSessionParams(session: widget.session, result: result),
    ).fold(
      (_) => Navigator.of(context).pop(),
      (completed) => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultsPage(session: completed)),
      ),
    );
  }

  Color get _centerColor => switch (_answer) {
        _Answer.correct => Colors.green.withValues(alpha: 0.15),
        _Answer.wrong   => Colors.red.withValues(alpha: 0.15),
        _Answer.none    => Colors.orange.withValues(alpha: 0.12),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.close),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 36,
                    child: Center(child: Text('$_currentIndex / $_total')),
                  ),
                  SizedBox(
                    width: 60,
                    height: 36,
                    child: Center(child: Text('✓ $_correctCount')),
                  ),
                ],
              ),
            ),

            // ── Center — note display ─────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: const Color.fromARGB(179, 247, 241, 229),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.session.showNoteName)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    _stepToLabel(_currentStep),
                                    style: const TextStyle(fontSize: 56),
                                  ),
                                ),
                              ),
                            SizedBox(height: 24,),
                            StaffWidget(
                              clef: widget.session.clef,
                              diatonicStep: _currentStep,
                              state: switch (_answer) {
                                _Answer.correct => NoteState.correct,
                                _Answer.wrong => NoteState.wrong,
                                _Answer.none => NoteState.idle,
                              },
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom — answer buttons ───────────────────────────────────────
            Column(
              children: [
                const Text('Joue la note sur ton clavier'),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(onPressed: _onCorrect, child: Text('test ✓', style: TextStyle(color: Colors.green),)),
                      const SizedBox(width: 16),
                      ElevatedButton(onPressed: _onWrong, child: Text('test ✗', style: TextStyle(color: Colors.red),)),

                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
