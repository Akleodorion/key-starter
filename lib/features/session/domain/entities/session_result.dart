import 'package:equatable/equatable.dart';

class SessionResult extends Equatable {
  final int correctCount;
  final int totalNotes;
  final int durationSec;
  final int bestStreak;
  final int avgResponseMs;

  const SessionResult({
    required this.correctCount,
    required this.totalNotes,
    required this.durationSec,
    required this.bestStreak,
    required this.avgResponseMs,
  });

  double get accuracy => correctCount / totalNotes;

  SessionResult copyWith({
    int? correctCount,
    int? totalNotes,
    int? durationSec,
    int? bestStreak,
    int? avgResponseMs,
  }) =>
      SessionResult(
        correctCount: correctCount ?? this.correctCount,
        totalNotes: totalNotes ?? this.totalNotes,
        durationSec: durationSec ?? this.durationSec,
        bestStreak: bestStreak ?? this.bestStreak,
        avgResponseMs: avgResponseMs ?? this.avgResponseMs,
      );

  @override
  List<Object?> get props => [
        correctCount,
        totalNotes,
        durationSec,
        bestStreak,
        avgResponseMs,
      ];
}
