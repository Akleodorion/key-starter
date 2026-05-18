import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/widgets/concept_badge.dart';
import 'package:key_starter/core/widgets/concept_info.dart';

class ConceptHeader extends StatelessWidget {
  final Concept concept;

  const ConceptHeader({super.key, required this.concept});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ConceptBadge(concept: concept),
        const SizedBox(width: 16),
        ConceptInfo(concept: concept),
      ],
    );
  }
}
