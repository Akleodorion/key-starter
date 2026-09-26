import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_bpm_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  TempoBpmNotifier sut() => container.read(tempoBpmProvider.notifier);

  group('TempoBpmNotifier', () {
    group('build', () {
      test('démarre à 60 BPM', () {
        //arrange
        //act
        final bpm = container.read(tempoBpmProvider);

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
        expect(container.read(tempoBpmProvider), 65);
      });

      test('ne dépasse pas 120 BPM', () {
        //arrange
        for (var step = 0; step < 20; step++) {
          sut().increment();
        }

        //act
        sut().increment();

        //assert
        expect(container.read(tempoBpmProvider), 120);
      });
    });

    group('decrement', () {
      test('diminue de 5 BPM', () {
        //arrange
        //act
        sut().decrement();

        //assert
        expect(container.read(tempoBpmProvider), 55);
      });

      test('ne descend pas sous 40 BPM', () {
        //arrange
        for (var step = 0; step < 20; step++) {
          sut().decrement();
        }

        //act
        sut().decrement();

        //assert
        expect(container.read(tempoBpmProvider), 40);
      });
    });
  });
}
