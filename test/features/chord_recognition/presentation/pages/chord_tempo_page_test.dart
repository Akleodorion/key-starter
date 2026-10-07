import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/chord_tempo_page.dart';

import '../../../../helpers/layout_test_helpers.dart';

void main() {
  group('ChordTempoPage', () {
    testNoOverflow('affiche les réglages', () => const ChordTempoPage());
  });
}
