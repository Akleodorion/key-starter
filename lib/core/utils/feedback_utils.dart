import 'package:flutter/material.dart';
import 'package:key_starter/core/widgets/feature_unavailable_toast.dart';

OverlayEntry? _currentToastEntry;

void showFeatureUnavailableToast(BuildContext context) {
  _currentToastEntry?.remove();

  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => FeatureUnavailableToast(
      message: "Cette fonctionnalité n'est pas encore disponible.",
      onDismissed: () {
        entry.remove();
        if (identical(_currentToastEntry, entry)) {
          _currentToastEntry = null;
        }
      },
    ),
  );
  _currentToastEntry = entry;
  overlay.insert(entry);
}
