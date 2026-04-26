import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SessionLocalDataSource {
  Future<void> saveLastParams(CreateSessionParams params);
  Future<CreateSessionParams?> getLastParams();
}

class SessionLocalDataSourceImpl implements SessionLocalDataSource {
  final SharedPreferences prefs;

  const SessionLocalDataSourceImpl({required this.prefs});

  static const _kClef = 'session_clef';
  static const _kMinNoteMidi = 'session_min_note_midi';
  static const _kMaxNoteMidi = 'session_max_note_midi';
  static const _kTotalNotes = 'session_total_notes';
  static const _kShowNoteName = 'session_show_note_name';
  static const _kLanguage = 'session_language';

  static const _noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F',
    'F#', 'G', 'G#', 'A', 'A#', 'B',
  ];

  static Note _noteFromMidi(int midi) => Note(
        midiNumber: midi,
        name: _noteNames[midi % 12],
        octave: midi ~/ 12 - 1,
      );

  @override
  Future<void> saveLastParams(CreateSessionParams params) async {
    try {
      await prefs.setString(_kClef, params.clef.name);
      await prefs.setInt(_kMinNoteMidi, params.minNote.midiNumber);
      await prefs.setInt(_kMaxNoteMidi, params.maxNote.midiNumber);
      await prefs.setInt(_kTotalNotes, params.totalNotes);
      await prefs.setBool(_kShowNoteName, params.showNoteName);
      await prefs.setString(_kLanguage, params.language.name);
    } catch (_) {
      throw const SharedPreferencesException();
    }
  }

  @override
  Future<CreateSessionParams?> getLastParams() async {
    try {
      final clefStr = prefs.getString(_kClef);
      if (clefStr == null) return null;

      final minMidi = prefs.getInt(_kMinNoteMidi);
      final maxMidi = prefs.getInt(_kMaxNoteMidi);
      final totalNotes = prefs.getInt(_kTotalNotes);
      final showNoteName = prefs.getBool(_kShowNoteName);
      final langStr = prefs.getString(_kLanguage);

      if (minMidi == null || maxMidi == null || totalNotes == null ||
          showNoteName == null || langStr == null) {
        return null;
      }

      return CreateSessionParams(
        clef: ClefMode.values.byName(clefStr),
        minNote: _noteFromMidi(minMidi),
        maxNote: _noteFromMidi(maxMidi),
        totalNotes: totalNotes,
        showNoteName: showNoteName,
        language: NoteLanguage.values.byName(langStr),
      );
    } catch (_) {
      throw const SharedPreferencesException();
    }
  }
}
