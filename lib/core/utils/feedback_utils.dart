import 'package:flutter/material.dart';
import 'package:key_starter/core/widgets/feature_unavailable_toast.dart';

OverlayEntry? _currentToastEntry;

void showFeatureUnavailableToast(BuildContext context) =>
    showToast(context, "Cette fonctionnalité n'est pas encore disponible.");

/// Affiche un message bref par-dessus la page ; remplace le précédent.
void showToast(BuildContext context, String message) {
  _currentToastEntry?.remove();

  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => FeatureUnavailableToast(
      message: message,
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
