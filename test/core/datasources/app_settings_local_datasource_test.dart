import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/datasources/app_settings_local_datasource.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<AppSettingsLocalDataSourceImpl> createSut(
    Map<String, Object> savedValues,
  ) async {
    SharedPreferences.setMockInitialValues(savedValues);
    return AppSettingsLocalDataSourceImpl(
      preferences: await SharedPreferences.getInstance(),
    );
  }

  group('AppSettingsLocalDataSourceImpl', () {
    test(
      'renvoie les réglages par défaut quand rien n\'est sauvegardé',
      () async {
        //arrange
        final sut = await createSut({});

        //act
        final themeMode = sut.themeMode;
        final language = sut.notationLanguage;
        final showNoteAid = sut.showNoteAid;

        //assert
        expect(themeMode, ThemeMode.system);
        expect(language, NoteLanguage.fr);
        expect(showNoteAid, isFalse);
      },
    );

    test('relit le thème enregistré', () async {
      //arrange
      final writer = await createSut({});
      await writer.saveThemeMode(ThemeMode.dark);
      final sut = AppSettingsLocalDataSourceImpl(
        preferences: await SharedPreferences.getInstance(),
      );

      //act
      final themeMode = sut.themeMode;

      //assert
      expect(themeMode, ThemeMode.dark);
    });

    test('relit la langue de notation enregistrée', () async {
      //arrange
      final writer = await createSut({});
      await writer.saveNotationLanguage(NoteLanguage.en);
      final sut = AppSettingsLocalDataSourceImpl(
        preferences: await SharedPreferences.getInstance(),
      );

      //act
      final language = sut.notationLanguage;

      //assert
      expect(language, NoteLanguage.en);
    });

    test('relit l\'aide aux noms de notes enregistrée', () async {
      //arrange
      final writer = await createSut({});
      await writer.saveShowNoteAid(true);
      final sut = AppSettingsLocalDataSourceImpl(
        preferences: await SharedPreferences.getInstance(),
      );

      //act
      final showNoteAid = sut.showNoteAid;

      //assert
      expect(showNoteAid, isTrue);
    });

    test('renvoie la valeur par défaut d\'un réglage illisible', () async {
      //arrange
      final sut = await createSut({
        'settings_theme_mode': 'sepia',
        'settings_notation_language': 'de',
        'settings_show_note_aid': 'oui',
      });

      //act
      final themeMode = sut.themeMode;
      final language = sut.notationLanguage;
      final showNoteAid = sut.showNoteAid;

      //assert
      expect(themeMode, ThemeMode.system);
      expect(language, NoteLanguage.fr);
      expect(showNoteAid, isFalse);
    });
  });
}
