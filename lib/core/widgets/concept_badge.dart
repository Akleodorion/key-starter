import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';

class ConceptBadge extends StatelessWidget {
  final Concept concept;

  const ConceptBadge({super.key, required this.concept});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? concept.darkTintColor : concept.tintColor;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(child: Icon(concept.icon, color: concept.color, size: 32)),
    );
  }
}
