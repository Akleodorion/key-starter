import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/note_recognition/presentation/pages/flashcard_page.dart';

import '../../../../helpers/layout_test_helpers.dart';

void main() {
  group('FlashcardPage', () {
    testNoOverflow('affiche les réglages', () => const FlashcardPage());
  });
}
