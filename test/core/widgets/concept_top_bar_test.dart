import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';

import '../../helpers/layout_test_helpers.dart';

void main() {
  group('ConceptTopBar', () {
    testNoOverflow(
      'affiche le titre « Accords » à côté de « Aucune entrée »',
      () => const Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ConceptTopBar(title: 'Accords'),
        ),
      ),
      overrides: () => [
        activeInputSourceKindProvider.overrideWithValue(InputSourceKind.none),
      ],
    );
  });
}
