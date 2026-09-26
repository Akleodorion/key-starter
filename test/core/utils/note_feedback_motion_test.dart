import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';

void main() {
  group('noteFeedbackScale', () {
    test('should swell a correct note up to 1.3 at mid-animation', () {
      //arrange
      const progress = 0.5;

      //act
      final sut = noteFeedbackScale(NoteState.correct, progress);

      //assert
      expect(sut, closeTo(1.3, 0.0001));
    });

    test('should bring a correct note back to its size at the end', () {
      //arrange
      const progress = 1.0;

      //act
      final sut = noteFeedbackScale(NoteState.correct, progress);

      //assert
      expect(sut, closeTo(1, 0.0001));
    });

    test('should never swell a wrong or idle note', () {
      //arrange
      const progress = 0.5;

      //act
      final wrongScale = noteFeedbackScale(NoteState.wrong, progress);
      final idleScale = noteFeedbackScale(NoteState.idle, progress);

      //assert
      expect(wrongScale, 1);
      expect(idleScale, 1);
    });
  });

  group('noteFeedbackShift', () {
    test('should shake a wrong note horizontally during the animation', () {
      //arrange
      const progress = 0.05;

      //act
      final sut = noteFeedbackShift(NoteState.wrong, progress);

      //assert
      expect(sut, isNot(0));
    });

    test('should put a wrong note back in place at the end', () {
      //arrange
      const progress = 1.0;

      //act
      final sut = noteFeedbackShift(NoteState.wrong, progress);

      //assert
      expect(sut, 0);
    });

    test('should never shake a correct or idle note', () {
      //arrange
      const progress = 0.05;

      //act
      final correctShift = noteFeedbackShift(NoteState.correct, progress);
      final idleShift = noteFeedbackShift(NoteState.idle, progress);

      //assert
      expect(correctShift, 0);
      expect(idleShift, 0);
    });
  });
}
