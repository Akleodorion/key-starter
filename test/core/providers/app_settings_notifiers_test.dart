import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/datasources/app_settings_local_datasource.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/providers/app_settings_datasource_provider.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/providers/show_note_aid_provider.dart';
import 'package:key_starter/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppSettingsLocalDataSourceImpl dataSource;

  Future<ProviderContainer> createContainer(
    Map<String, Object> savedValues,
  ) async {
    SharedPreferences.setMockInitialValues(savedValues);
    dataSource = AppSettingsLocalDataSourceImpl(
      preferences: await SharedPreferences.getInstance(),
    );
    final container = ProviderContainer(
      overrides: [
        appSettingsLocalDataSourceProvider.overrideWithValue(dataSource),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ThemeNotifier', () {
    test('démarre sur le thème sauvegardé', () async {
      //arrange
      final container = await createContainer({'settings_theme_mode': 'dark'});

      //act
      final sut = container.read(themeProvider);

      //assert
      expect(sut, ThemeMode.dark);
    });

    group('setMode', () {
      test('enregistre le thème choisi', () async {
        //arrange
        final container = await createContainer({});

        //act
        container.read(themeProvider.notifier).setMode(ThemeMode.light);

        //assert
        expect(container.read(themeProvider), ThemeMode.light);
        expect(dataSource.themeMode, ThemeMode.light);
      });
    });
  });

  group('NotationLanguageNotifier', () {
    test('démarre sur la langue sauvegardée', () async {
      //arrange
      final container = await createContainer({
        'settings_notation_language': 'en',
      });

      //act
      final sut = container.read(notationLanguageProvider);

      //assert
      expect(sut, NoteLanguage.en);
    });

    group('setLanguage', () {
      test('enregistre la langue choisie', () async {
        //arrange
        final container = await createContainer({});

        //act
        container
            .read(notationLanguageProvider.notifier)
            .setLanguage(NoteLanguage.en);

        //assert
        expect(container.read(notationLanguageProvider), NoteLanguage.en);
        expect(dataSource.notationLanguage, NoteLanguage.en);
      });
    });
  });

  group('ShowNoteAidNotifier', () {
    test('démarre sur l\'aide sauvegardée', () async {
      //arrange
      final container = await createContainer({'settings_show_note_aid': true});

      //act
      final sut = container.read(showNoteAidProvider);

      //assert
      expect(sut, isTrue);
    });

    group('toggle', () {
      test('enregistre la nouvelle valeur', () async {
        //arrange
        final container = await createContainer({});

        //act
        container.read(showNoteAidProvider.notifier).toggle();

        //assert
        expect(container.read(showNoteAidProvider), isTrue);
        expect(dataSource.showNoteAid, isTrue);
      });
    });

    group('setValue', () {
      test('enregistre la valeur choisie', () async {
        //arrange
        final container = await createContainer({
          'settings_show_note_aid': true,
        });

        //act
        container.read(showNoteAidProvider.notifier).setValue(false);

        //assert
        expect(container.read(showNoteAidProvider), isFalse);
        expect(dataSource.showNoteAid, isFalse);
      });
    });
  });
}
