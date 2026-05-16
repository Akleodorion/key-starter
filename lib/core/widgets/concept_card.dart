import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/widgets/secondary_icon_button.dart';

class ConceptCard extends StatelessWidget {
  final Concept concept;
  final VoidCallback? onTap;

  const ConceptCard({super.key, required this.concept, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: concept.color.withValues(alpha: 0.08),
        border: Border.all(color: concept.color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(concept.icon, color: concept.color, size: 28),
          const SizedBox(height: 16),
          Text(
            concept.title,
            style: AppTextStyles.ui(size: 18, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  concept.description,
                  style: AppTextStyles.ui(size: 13, color: AppColors.text2),
                ),
              ),
              SecondaryIconButton(
                icon: Icons.arrow_forward_rounded,
                color: concept.color,
                onTap: onTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
