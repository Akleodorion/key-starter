import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_bpm_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  ChordTempoBpmNotifier sut() => container.read(chordTempoBpmProvider.notifier);

  group('ChordTempoBpmNotifier', () {
    group('build', () {
      test('démarre à 60 BPM', () {
        //arrange
        //act
        final bpm = container.read(chordTempoBpmProvider);

        //assert
        expect(bpm, 60);
      });
    });

    group('increment', () {
      test('augmente de 5 BPM', () {
        //arrange
        //act
        sut().increment();

        //assert
        expect(container.read(chordTempoBpmProvider), 65);
      });

      test('ne dépasse pas 120 BPM', () {
        //arrange
        for (var step = 0; step < 20; step++) {
          sut().increment();
        }

        //act
        sut().increment();

        //assert
        expect(container.read(chordTempoBpmProvider), 120);
      });
    });

    group('decrement', () {
      test('diminue de 5 BPM', () {
        //arrange
        //act
        sut().decrement();

        //assert
        expect(container.read(chordTempoBpmProvider), 55);
      });

      test('ne descend pas sous 40 BPM', () {
        //arrange
        for (var step = 0; step < 20; step++) {
          sut().decrement();
        }

        //act
        sut().decrement();

        //assert
        expect(container.read(chordTempoBpmProvider), 40);
      });
    });
  });
}
