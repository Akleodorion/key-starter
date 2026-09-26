import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_black_keys_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  group('SimpleNoteBlackKeysNotifier', () {
    group('build', () {
      test('exclut les touches noires par défaut', () {
        //act
        final includeBlackKeys = container.read(simpleNoteBlackKeysProvider);

        //assert
        expect(includeBlackKeys, isFalse);
      });
    });

    group('setValue', () {
      test('inclut les touches noires une fois activé', () {
        //arrange
        final sut = container.read(simpleNoteBlackKeysProvider.notifier);

        //act
        sut.setValue(true);

        //assert
        expect(container.read(simpleNoteBlackKeysProvider), isTrue);
      });
    });
  });
}
