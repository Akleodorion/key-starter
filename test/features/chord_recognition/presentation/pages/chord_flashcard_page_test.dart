import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/chord_flashcard_page.dart';

import '../../../../helpers/layout_test_helpers.dart';

void main() {
  group('ChordFlashcardPage', () {
    testNoOverflow('affiche les réglages', () => const ChordFlashcardPage());
  });
}
