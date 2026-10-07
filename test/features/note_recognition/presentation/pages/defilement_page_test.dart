import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/note_recognition/presentation/pages/defilement_page.dart';

import '../../../../helpers/layout_test_helpers.dart';

void main() {
  group('DefilementPage', () {
    testNoOverflow('affiche les réglages', () => const DefilementPage());
  });
}
