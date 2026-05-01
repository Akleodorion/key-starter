import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/providers/midi_note_provider.dart';
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

  int _currentIndex = 0;
  int _correctCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  _Answer _answer = _Answer.none;
  late int _currentStep;
  late DateTime _noteShownAt;

  int get _total => widget.session.totalNotes;

  @override
  void initState() {
    super.initState();
    _currentStep = _pickStep();
    _noteShownAt = DateTime.now();
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
    final ms = DateTime.now().difference(_noteShownAt).inMilliseconds;
    _responseTimes.add(ms);
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
    final ms = DateTime.now().difference(_noteShownAt).inMilliseconds;
    _responseTimes.add(ms);
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
    ref.listen<AsyncValue<int>>(midiNoteOnProvider, (_, next) {
      next.whenData((midiNumber) {
        if (midiNumber == _stepToMidi(_currentStep)) {
          _onCorrect();
        } else {
          _onWrong();
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Container(
              color: Colors.blue.withValues(alpha: 0.25),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.blue.withValues(alpha: 0.4),
                      child: const Icon(Icons.close),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 36,
                    color: Colors.blue.withValues(alpha: 0.4),
                    child: Center(child: Text('$_currentIndex / $_total')),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 36,
                    color: Colors.green.withValues(alpha: 0.4),
                    child: Center(child: Text('✓ $_correctCount')),
                  ),
                ],
              ),
            ),

            // ── Center — note display ─────────────────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    color: _centerColor,
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.session.showNoteName)
                          Container(
                            color: Colors.yellow.withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                _stepToLabel(_currentStep),
                                style: const TextStyle(fontSize: 56),
                              ),
                            ),
                          ),
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

            // ── Bottom — answer buttons ───────────────────────────────────────
            Column(
              children: [
                const Text('Joue la note sur ton clavier'),
                Container(
                  color: Colors.purple.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _onCorrect,
                          child: Container(
                            height: 56,
                            color: Colors.green.withValues(alpha: 0.4),
                            child: const Center(child: Text('✓ Bonne réponse')),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: _onWrong,
                          child: Container(
                            height: 56,
                            color: Colors.red.withValues(alpha: 0.4),
                            child: const Center(child: Text('✗ Mauvaise réponse')),
                          ),
                        ),
                      ),
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
