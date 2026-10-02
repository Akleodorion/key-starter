import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/utils/held_keys_tracker.dart';

void main() {
  group('HeldKeysTracker', () {
    group('press', () {
      test(
        'attend tant que moins de touches que prévu sont tenues ensemble',
        () {
          //arrange
          final sut = HeldKeysTracker(expectedKeyCount: 3);
          sut.press(48);

          //act
          final outcome = sut.press(72);

          //assert
          expect(outcome, const HeldKeysPending());
        },
      );

      test(
        'est complet dès que le nombre prévu de touches est tenu ensemble, quel que soit l\'ordre',
        () {
          //arrange
          final sut = HeldKeysTracker(expectedKeyCount: 3);
          sut.press(72);
          sut.press(48);

          //act
          final outcome = sut.press(52);

          //assert
          expect(outcome, const HeldKeysComplete({48, 52, 72}));
        },
      );
    });

    group('release', () {
      test(
        'abandonne la tentative avec toutes les touches jouées si une touche est relâchée trop tôt',
        () {
          //arrange
          final sut = HeldKeysTracker(expectedKeyCount: 3);
          sut.press(48);
          sut.press(72);

          //act
          final outcome = sut.release(48);

          //assert
          expect(outcome, const HeldKeysAbandoned({48, 72}));
        },
      );

      test('ignore le relâchement d\'une touche qui n\'est pas tenue', () {
        //arrange
        final sut = HeldKeysTracker(expectedKeyCount: 2);
        sut.press(48);

        //act
        final outcome = sut.release(60);

        //assert
        expect(outcome, const HeldKeysPending());
      });
    });
  });
}
