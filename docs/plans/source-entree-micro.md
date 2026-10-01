# Plan — Source d'entrée Micro en repli du MIDI

Décisions : [ADR 0001](../adr/0001-midi-prioritaire-micro-en-repli.md). Vocabulaire : `CONTEXT.md` (Source d'entrée, Vérification guidée, Attaque, Seuil d'écoute).

Deux PR successives, chacune partie de `master`.

---

## PR 1 — Remise à plat de l'entrée MIDI (aucun changement visible)

**But** : tous les exercices reçoivent leurs notes par une seule abstraction `InputSource`. L'app se comporte exactement comme avant.

### État actuel
- Six notifiers s'abonnent chacun à `MidiCommand().onMidiDataReceived` dans `build()` et parsent eux-mêmes les octets :
  - `simple_note_exercise_notifier.dart`, `flashcard_exercise_notifier.dart`, `defilement_exercise_notifier.dart`, `tempo_exercise_notifier.dart` (feature `note_recognition`) ;
  - `chord_flashcard_exercise_notifier.dart`, `simple_chord_exercise_notifier.dart` (feature `chord_recognition`).
- **Couche morte** : `MidiDataSource`, `NoteRecognitionRepository(Impl)`, `RecognizeNoteUseCase`, `NoteRecognitionNotifier/Provider/State`, leurs enregistrements dans `injection_container.dart`, et `core/providers/midi_note_provider.dart`. Aucun exercice ne les utilise.
- **Point d'attention** : l'entité `Note` est utilisée par `session_local_datasource.dart`, elle doit être conservée.

### Étapes
1. **Modèle d'événements** dans `lib/core/input/` (partagé par les deux features, puisque les imports entre features sont interdits) :
   - `InputEvent` (sealed), avec `NotePlayed(midiNumber, attackTime)` et `NoteReleased(midiNumber)`, en Equatable ;
   - interface `InputSource` : `Stream<InputEvent> events` et `void listenFor(Set<int> candidateMidiNumbers)`. La source MIDI ignore `listenFor`.
2. **`MidiInputSource`** :
   - un parsing Note On / Note Off unique (y compris Note On à vélocité 0) ;
   - un `Stream<MidiPacket>` injecté pour pouvoir le tester.
   - Une seule instance de `MidiCommand` est exposée par un provider, réutilisé par `midiConnectionProvider`.
   - Tests : vrais octets MIDI (on, off, vélocité 0, paquets courts, autres canaux).
3. **`inputSourceProvider`** : il expose la source active. Dans cette PR, c'est toujours la source MIDI. Les tests le surchargent par une `FakeInputSource`.
4. **Migration des 6 notifiers** : on s'abonne à `inputSourceProvider` au lieu de `MidiCommand()`, et on appelle `listenFor` à chaque nouvelle cible.
   - Notes simples : toutes les octaves de la classe de hauteur. Flashcard et Défilement : la note MIDI exacte. Accords : les 3 notes. Tempo : la note de la fenêtre en cours.
   - Flashcard : le temps de réponse se calcule depuis `attackTime`, et non plus depuis `DateTime.now()`.
   - `simulateMidi` (boutons « Juste/Faux ») reste inchangé.
5. **Suppression de la couche morte** et de ses tests, en conservant l'entité `Note`.

**Filet de sécurité** : les tests de notifiers et d'intégration existants doivent rester verts sans modification de leurs assertions.

---

## PR 2 — Source Micro

### 1. Portage de l'analyse (Dart pur)
- Depuis le worktree POC, on porte `piano_audio_analyzer.dart` et `single_note_listener.dart` vers `lib/core/input/audio/`. **On garde tous les seuils réglés.**
- Nettoyage :
  - l'état global modifiable (`lowerOctaveLimit`, `ghostLimit`, FFT partagées) passe en paramètres ou en champs ;
  - on retire le code de diagnostic (`trace`, `debugRejections`, `lastIgnoredReason`…) ;
  - on respecte les règles de nommage du `CLAUDE.md`.
- **Seuil d'écoute** : une constante `minimumGate = 10^(-55/20) ≈ 0,0018` remplace le paramètre modifiable. Le suivi du bruit (`noiseFloor × gateFactor`) est conservé.
- `NoteAttemptResult` expose l'**instant de l'attaque**, au lieu d'une `latencyMs` estimée.
- `listenFor` accepte **plusieurs candidats**, pour Notes simples où l'octave est libre : `TargetNoteListener` remplace `SingleNoteListener`. Il partage un seul tampon audio, un seul apprentissage du bruit de fond et les deux analyseurs ; chaque candidat garde sa bande de fréquences, son seuil et son suivi d'attaque. Le premier candidat qui tranche décide. *Mesuré* : 8 candidats coûtent autant qu'un seul au repos (~60 ms de calcul pour 2,5 s de son sur Mac), alors que 8 listeners indépendants coûtaient ~520 ms.
- `NoteDebouncer` et les fonctions de transcription aveugle (chroma, `bestTriad`) ne sont pas portés.
- `tool/audio_detection_prototype_bench.dart` **n'est pas repris** : il reposait sur la transcription aveugle (`analyze`) et sur les échantillons WAV de l'Iowa. Il reste disponible sur la branche `prototype-audio-detection`. Les pages prototype ne sont pas reprises non plus.

### 2. Tests de l'analyse
- **Signaux synthétiques générés dans les tests** : partiels avec inharmonicité ; bonne note ; mauvaise note ; mauvaise octave ; bruit seul ; volume sous -55 dB ; attaque puis résonance (la résonance d'une cible ne valide pas une seconde fois) ; plusieurs candidats.
- **Pas de fixtures WAV** : la détection a déjà été validée en direct sur le synthé de Christian. Les tests automatisés reposent uniquement sur des signaux synthétiques.

### 3. `MicrophoneInputSource`
- **Capture** : `record` (`startStream`, pcm16, 44,1 kHz, mono, `autoGain`/`echoCancel`/`noiseSuppress` désactivés), puis conversion Int16 → double.
- Le micro n'est **ouvert que lorsqu'il est la source active et qu'une cible est armée**. Il est fermé hors exercice.
- **Événements émis** :
  - cible validée → `NotePlayed(cible, attackTime)` ;
  - autre note entendue nettement → `NotePlayed(noteEntendue, attackTime)` ;
  - sinon, rien.
  - **Pas de vrai Note Off au micro.** Pour que l'anti-répétition de Flashcard et Défilement fonctionne sans changer les notifiers, chaque `NotePlayed` est aussitôt suivi d'un `NoteReleased`, et l'écoute s'arrête jusqu'au prochain `listenFor` : une réponse au micro est toujours une nouvelle attaque.
- Dépendances : `record`, `fftea`. Permission Android `RECORD_AUDIO`. iOS `NSMicrophoneUsageDescription` (texte définitif, sans « PROTOTYPE »).
- **Pas de modification macOS** : on ne reprend ni le passage en 12.0 ni les entitlements du POC.

### 4. Sélection automatique et bascule à chaud
- `inputSourceProvider` choisit MIDI si `midiConnectionProvider` voit un appareil, sinon Micro si la permission est accordée, sinon « Aucune entrée ».
- **Façade unique** : les notifiers gardent un seul abonnement. La façade relaie les événements de la source active et **réarme la nouvelle source avec la dernière cible** lors d'une bascule. L'exercice ne redémarre pas.
- **Toast de bascule** dans les pages d'exercice, sur changement de type de source : « Clavier MIDI connecté » / « Passage au micro » (`MicrophoneExerciseFrame`).

### 5. Permission micro
- Demandée **une seule fois, au premier démarrage**, même si un MIDI est branché (`permission_handler`).
- Si elle est refusée et qu'aucun MIDI n'est connecté, l'exercice affiche un `MaterialBanner` « Branchez un clavier MIDI ou autorisez le micro dans les réglages », avec un bouton qui ouvre les réglages. L'autorisation est relue à chaque retour dans l'app.

### 6. Pastille de source
- `MidiPill` devient `InputSourcePill` : « MIDI · nom de l'appareil » / « Micro » / « Aucune entrée ».
- Mêmes trois emplacements : `concept_top_bar.dart`, `exercise_top_bar.dart`, `home_top_bar.dart`.

### 7. Exercices réservés au MIDI (Accords, Accords simples, Tempo)
- **Sans MIDI** : carte grisée sur l'accueil et les pages de concept. Au toucher, un toast « Branchez un clavier MIDI pour cet exercice » (même mécanisme que `showFeatureUnavailableToast`).
- **Débranchement en cours d'exercice** : pause avec « Clavier MIDI déconnecté — rebranchez-le ou quittez ». Reprise automatique au rebranchement. Pour Tempo, la chronologie doit être suspendue puis reprise ; c'est le point le plus délicat de cette étape, à tester avec une horloge injectée.

### 8. Tests de bout en bout
- Notifiers : `FakeInputSource` pour la bascule MIDI → Micro en cours de question (la cible est réarmée), et pour la pause et la reprise des exercices réservés au MIDI.
- Widgets : la pastille (3 états), les cartes grisées et le message d'absence d'entrée.
- Test manuel sur Android et iOS avec le synthé, sans câble : Notes simples, Flashcard, Défilement, puis branchement du câble en cours d'exercice.

---

## Hors périmètre
- Accords et Tempo au micro (nouveau POC à prévoir).
- Boutons de triche « Juste/Faux » toujours visibles dans les exercices.
- Sélection manuelle de source, MIDI Bluetooth, réglage de sensibilité.
