import 'package:flutter/material.dart';

class ChordChartLoadingView extends StatelessWidget {
  const ChordChartLoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
