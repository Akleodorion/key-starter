import 'package:flutter/material.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';

class LessonPage extends StatelessWidget {
  final Session session;

  const LessonPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Container(
              color: Colors.blue.withValues(alpha: 0.25),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.blue.withValues(alpha: 0.4),
                      child: const Icon(Icons.close),
                    ),
                  ),
                  const Spacer(),
                  // Note counter
                  Container(
                    width: 60,
                    height: 36,
                    color: Colors.blue.withValues(alpha: 0.4),
                    child: const Center(child: Text('0 / 20')),
                  ),
                  const Spacer(),
                  // Correct counter
                  Container(
                    width: 60,
                    height: 36,
                    color: Colors.green.withValues(alpha: 0.4),
                    child: const Center(child: Text('✓ 0')),
                  ),
                ],
              ),
            ),

            // ── Center — note display ─────────────────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    color: Colors.orange.withValues(alpha: 0.12),
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Note name (conditionally shown)
                        if (session.showNoteName)
                          Container(
                            color: Colors.yellow.withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: const Center(
                              child: Text(
                                'Sol 3',
                                style: TextStyle(fontSize: 56),
                              ),
                            ),
                          ),

                        // Staff placeholder
                        Container(
                          height: 100,
                          color: Colors.orange.withValues(alpha: 0.3),
                          child: const Center(child: Text('Portée')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom — answer buttons ───────────────────────────────────────
            Container(
              color: Colors.purple.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: List.generate(
                      2,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                          child: Container(
                            height: 56,
                            color: Colors.purple.withValues(alpha: 0.4),
                            child: Center(child: Text('Bouton ${i + 1}')),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
