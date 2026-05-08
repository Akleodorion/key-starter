import 'package:flutter/material.dart';
import 'package:key_starter/features/session/presentation/widgets/session_staff_widget.dart';

/// Bandeau d'en-tête de la page de configuration.
class SessionSetupHeader extends StatelessWidget {
  const SessionSetupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: Colors.black26,
            child: const Column(
              children: [
                Text("AUJOURD'HUI"),
                Text('Une session lecture', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Container(
            color: Colors.black26,
            child: const SessionStaffWidget(staffwidth: 175),
          ),
        ],
      ),
    );
  }
}
