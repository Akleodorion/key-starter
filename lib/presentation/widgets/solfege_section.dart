import 'package:flutter/material.dart';
import 'package:key_starter/presentation/widgets/notation_settings_row.dart';
import 'package:key_starter/presentation/widgets/note_aid_toggle_row.dart';
import 'package:key_starter/presentation/widgets/settings_section_data.dart';

class SolfegeSection extends SettingsSectionData {
  const SolfegeSection();

  @override
  String get title => 'Solfège';

  @override
  List<Widget> get children => const [
        NotationSettingsRow(),
        NoteAidToggleRow(),
      ];
}
