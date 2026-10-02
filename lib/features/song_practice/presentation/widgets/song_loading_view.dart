import 'package:flutter/material.dart';

class SongLoadingView extends StatelessWidget {
  const SongLoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
