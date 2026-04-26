import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/features/note_recognition/domain/entities/note.dart';
import 'package:key_starter/features/session/data/datasources/session_local_datasource.dart';
import 'package:key_starter/features/session/domain/usecases/create_session_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SessionLocalDataSourceImpl sut;

  const tParams = CreateSessionParams(
    clef: ClefMode.treble,
    minNote: Note(midiNumber: 64, name: 'E', octave: 4),
    maxNote: Note(midiNumber: 77, name: 'F', octave: 5),
    totalNotes: 25,
    showNoteName: false,
    language: NoteLanguage.fr,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    sut = SessionLocalDataSourceImpl(prefs: prefs);
  });

  group('SessionLocalDataSourceImpl', () {
    group('saveLastParams / getLastParams', () {
      test('retourne null quand aucun param n\'a été sauvegardé', () async {
        //act
        final result = await sut.getLastParams();

        //assert
        expect(result, isNull);
      });

      test('sauvegarde et restitue les params correctement', () async {
        //arrange
        await sut.saveLastParams(tParams);

        //act
        final result = await sut.getLastParams();

        //assert
        expect(result, equals(tParams));
      });

      test('restitue la clé de sol correctement', () async {
        //arrange
        await sut.saveLastParams(tParams);

        //act
        final result = await sut.getLastParams();

        //assert
        expect(result?.clef, ClefMode.treble);
      });

      test('restitue la clé de fa correctement', () async {
        //arrange
        const bassParams = CreateSessionParams(
          clef: ClefMode.bass,
          minNote: Note(midiNumber: 43, name: 'G', octave: 2),
          maxNote: Note(midiNumber: 57, name: 'A', octave: 3),
          totalNotes: 10,
          showNoteName: true,
          language: NoteLanguage.en,
        );
        await sut.saveLastParams(bassParams);

        //act
        final result = await sut.getLastParams();

        //assert
        expect(result?.clef, ClefMode.bass);
        expect(result?.language, NoteLanguage.en);
        expect(result?.showNoteName, isTrue);
      });

      test('écrase les anciens params lors d\'une nouvelle sauvegarde', () async {
        //arrange
        await sut.saveLastParams(tParams);
        const updatedParams = CreateSessionParams(
          clef: ClefMode.bass,
          minNote: Note(midiNumber: 43, name: 'G', octave: 2),
          maxNote: Note(midiNumber: 57, name: 'A', octave: 3),
          totalNotes: 50,
          showNoteName: true,
          language: NoteLanguage.en,
        );

        //act
        await sut.saveLastParams(updatedParams);
        final result = await sut.getLastParams();

        //assert
        expect(result?.totalNotes, 50);
        expect(result?.clef, ClefMode.bass);
      });
    });
  });
}
