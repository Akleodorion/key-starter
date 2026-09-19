import 'package:flutter/material.dart';

/// Contrat d'une section de la page Réglages.
///
/// Regroupe un titre et la liste des lignes de réglage ([children]) affichées
/// sous ce titre. Les sous-classes fournissent [title] et [children].
///
/// ```dart
/// class ThemeSection extends SettingsSectionData {
///   const ThemeSection();
///
///   @override String get title => 'Apparence';
///   @override List<Widget> get children => const [ThemeSettingsRow()];
/// }
/// ```
///
/// Voir aussi : [ThemeSection], [SolfegeSection]
abstract class SettingsSectionData {
  const SettingsSectionData();

  String get title;
  List<Widget> get children;
}
