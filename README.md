# Key Starter

Application Flutter d'apprentissage du piano, pensée comme une « voie du karaté » : une progression structurée, exercice après exercice, de la lecture d'une note au jeu d'un morceau à deux mains.

L'élève joue sur un vrai clavier : en **MIDI** quand un clavier est branché, sinon au **micro** (pour les exercices sur une seule note).

## Ce qu'on peut travailler

- **Notes** : Notes simples (avec ou sans touches noires), Flashcard, Défilement, Tempo.
- **Accords** (MIDI) : Accords simples, Renversements, Flashcard Accords, Tempo Accords.
- **Morceaux** (MIDI) : partitions MusicXML sur portée double, qui défilent ; travail par section, main droite, main gauche ou deux mains, en tempo libre ou de 40 à 120 à la noire.

## Démarrer

```bash
flutter pub get
flutter run
```

Les morceaux livrés sont dans `assets/songs/`. Les morceaux sous droits, pour un usage personnel, se déposent dans `assets/songs/local/` : ce dossier n'est pas versionné.

## Commandes utiles

```bash
flutter test                 # tests unitaires et de widgets
flutter test integration_test  # exercices joués avec un clavier MIDI simulé (appareil ou simulateur)
flutter analyze              # analyse statique
dart run custom_lint         # règles maison (key_starter_lints/)
flutter pub run build_runner build --delete-conflicting-outputs  # mocks
```

## Pour aller plus loin

- [`CONTEXT.md`](CONTEXT.md) : le vocabulaire du domaine (groupe de notes, renversement, section, fenêtre d'événement…).
- [`CLAUDE.md`](CLAUDE.md) : l'architecture (Clean Architecture par feature, Riverpod 3, get_it, dartz) et les règles de code et de test.
- [`docs/adr/`](docs/adr/) : les décisions d'architecture.
