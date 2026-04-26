import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/session/domain/entities/session_result.dart';

void main() {
  const tResult = SessionResult(
    correctCount: 22,
    totalNotes: 25,
    durationSec: 96,
    bestStreak: 14,
    avgResponseMs: 1240,
  );

  group('SessionResult', () {
    group('accuracy', () {
      test('retourne la fraction correctCount / totalNotes', () {
        //assert
        expect(tResult.accuracy, closeTo(0.88, 0.001));
      });

      test('retourne 1.0 pour une session parfaite', () {
        //arrange
        const perfect = SessionResult(
          correctCount: 25,
          totalNotes: 25,
          durationSec: 60,
          bestStreak: 25,
          avgResponseMs: 900,
        );

        //assert
        expect(perfect.accuracy, 1.0);
      });
    });

    group('équalité', () {
      test('deux instances avec les mêmes props sont égales', () {
        //arrange
        const other = SessionResult(
          correctCount: 22,
          totalNotes: 25,
          durationSec: 96,
          bestStreak: 14,
          avgResponseMs: 1240,
        );

        //assert
        expect(tResult, equals(other));
      });

      test('deux instances avec des props différentes ne sont pas égales', () {
        //arrange
        const other = SessionResult(
          correctCount: 10,
          totalNotes: 25,
          durationSec: 96,
          bestStreak: 14,
          avgResponseMs: 1240,
        );

        //assert
        expect(tResult, isNot(equals(other)));
      });
    });

    group('copyWith', () {
      test('sans argument retourne une instance équivalente', () {
        //act
        final result = tResult.copyWith();

        //assert
        expect(result, equals(tResult));
      });

      test('met à jour uniquement le champ spécifié', () {
        //act
        final result = tResult.copyWith(correctCount: 25);

        //assert
        expect(result.correctCount, 25);
        expect(result.totalNotes, tResult.totalNotes);
        expect(result.durationSec, tResult.durationSec);
        expect(result.bestStreak, tResult.bestStreak);
        expect(result.avgResponseMs, tResult.avgResponseMs);
      });
    });
  });
}
