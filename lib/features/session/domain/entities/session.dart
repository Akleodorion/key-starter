import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/domain/entities/session_result.dart';

class Session extends Equatable {
  final String id;
  final ClefMode clef;
  final Note minNote;
  final Note maxNote;
  final int totalNotes;
  final bool showNoteName;
  final NoteLanguage language;
  final DateTime startedAt;
  final SessionResult? result;

  const Session({
    required this.id,
    required this.clef,
    required this.minNote,
    required this.maxNote,
    required this.totalNotes,
    required this.showNoteName,
    required this.language,
    required this.startedAt,
    this.result,
  });

  bool get isCompleted => result != null;

  Session copyWith({
    String? id,
    ClefMode? clef,
    Note? minNote,
    Note? maxNote,
    int? totalNotes,
    bool? showNoteName,
    NoteLanguage? language,
    DateTime? startedAt,
    SessionResult? result,
  }) =>
      Session(
        id: id ?? this.id,
        clef: clef ?? this.clef,
        minNote: minNote ?? this.minNote,
        maxNote: maxNote ?? this.maxNote,
        totalNotes: totalNotes ?? this.totalNotes,
        showNoteName: showNoteName ?? this.showNoteName,
        language: language ?? this.language,
        startedAt: startedAt ?? this.startedAt,
        result: result ?? this.result,
      );

  @override
  List<Object?> get props => [
        id,
        clef,
        minNote,
        maxNote,
        totalNotes,
        showNoteName,
        language,
        startedAt,
        result,
      ];
}
