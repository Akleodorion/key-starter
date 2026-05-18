import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/clef_mode.dart';

class FlashcardSettings extends Equatable {
  final ClefMode clef;
  final int noteCount;

  const FlashcardSettings({required this.clef, required this.noteCount});

  FlashcardSettings copyWith({ClefMode? clef, int? noteCount}) => FlashcardSettings(
        clef: clef ?? this.clef,
        noteCount: noteCount ?? this.noteCount,
      );

  @override
  List<Object?> get props => [clef, noteCount];
}
