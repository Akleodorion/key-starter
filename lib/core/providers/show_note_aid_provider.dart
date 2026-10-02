import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/app_settings_datasource_provider.dart';

final showNoteAidProvider = NotifierProvider<ShowNoteAidNotifier, bool>(
  ShowNoteAidNotifier.new,
);

class ShowNoteAidNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(appSettingsLocalDataSourceProvider).showNoteAid;

  void toggle() => setValue(!state);

  void setValue(bool value) {
    state = value;
    ref.read(appSettingsLocalDataSourceProvider).saveShowNoteAid(value);
  }
}
