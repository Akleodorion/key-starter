import 'package:flutter/material.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';

class LessonPage extends StatelessWidget {
  final Session session;

  const LessonPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text('Leçon — en construction'),
      ),
    );
  }
}
