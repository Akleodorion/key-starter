# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

A Flutter proof-of-concept app to teach piano key recognition using a "karate way" (progressive, structured learning) approach.

## Common Commands

```bash
flutter run              # Run on connected device/simulator
flutter test             # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
flutter analyze          # Run static analysis (dart analyze)
flutter pub get          # Install dependencies
flutter pub run build_runner build --delete-conflicting-outputs  # Regenerate mocks after changing a repository interface
```

## Architecture

Clean Architecture with feature-based folder structure:

```
lib/
  core/           # shared errors, utils, widgets, enums
  features/
    <feature>/
      data/
        datasources/
        models/       # extends domain entity, adds fromJson/toJson
        repositories/ # implements domain interface
      domain/
        entities/     # pure Dart, Equatable
        repositories/ # abstract interface
        usecases/     # one class per use case, exposes call()
      presentation/
        pages/
        providers/    # notifier + provider file + state file
  injection_container.dart
  main.dart
test/               # mirrors lib/ structure
```

State management: **Riverpod 3.x** (`Notifier<State>` + `NotifierProvider` — `StateNotifier` was removed in Riverpod 3.x).  
DI: **get_it** (`registerLazySingleton` for stateless services like repositories and datasources; `registerFactory` only when a new instance is genuinely needed per call).  
Error handling: **dartz** `Either<Failure, T>` — never use `!` on an `Either`, it is never nullable.  
Value equality: **equatable** on all entities and state classes.

## Implemented Features

### note_recognition
Converts a raw MIDI number (0–127) into a `Note` entity.  
- `MidiDataSourceImpl.noteFromMidiNumber(int)` — pure sync conversion, throws `MidiException` on out-of-range.  
- `NoteRecognitionRepositoryImpl.recognizeNote(int)` — sync `Either<Failure, Note>`.  
- `NoteRecognitionNotifier` (Riverpod `Notifier`) exposes `onMidiNoteReceived(int midiNumber)`.  
- `recognizeNoteUseCaseProvider` is declared inside the notifier file to avoid circular imports.

### session
Manages a practice session lifecycle (create → play → complete).

**Domain entities:**
- `Session` — id, clef, minNote, maxNote, totalNotes, showNoteName, language, startedAt, result?. `isCompleted = result != null`.
- `SessionResult` — correctCount, totalNotes, durationSec, bestStreak, avgResponseMs. `accuracy = correctCount / totalNotes`.

**Use cases:**
- `CreateSessionUseCase(CreateSessionParams)` → `Future<Either<Failure, Session>>`
- `CompleteSessionUseCase(CompleteSessionParams)` → `Either<Failure, Session>` (sync, no I/O)
- `GetLastSessionParamsUseCase()` → `Future<Either<Failure, CreateSessionParams?>>`

**Persistence:** `SessionLocalDataSourceImpl` uses SharedPreferences to store the last `CreateSessionParams` (keys: `session_clef`, `session_min_note_midi`, `session_max_note_midi`, `session_total_notes`, `session_show_note_name`, `session_language`).

**Validation in `SessionRepositoryImpl`:** `totalNotes` must be 5–100; `minNote.midiNumber < maxNote.midiNumber`.

## Coding Rules

### Naming
- All identifiers and file names in **English** (not French). String messages displayed to the user may be in French.
- `entities/` (plural) — never `entitie/`
- `datasources/` — never `date_source`
- `resource` — never `ressource`
- Spell `batchesCounter`, `evaluation`, `function` correctly in identifiers.

### Entities & Models
- Domain entity: pure Dart class, `extends Equatable`, all fields `final`, no framework imports.
- Data model: `extends` the entity, adds `factory fromJson` / `toJson`. Nothing else.
- `copyWith` must follow standard Flutter convention — optional named parameters for each field, not a full replacement object:
  ```dart
  // correct
  Item copyWith({String? name, SuperPrice? superPrice}) => Item(
        id: id, name: name ?? this.name, superPrice: superPrice ?? this.superPrice, ...);
  ```

### State Classes
Sealed state hierarchy per feature: `Initial`, `Loading`, `Loaded`, `Error` — each `extends Equatable`.  
`Loaded` must expose a `copyWith`.  
`NoParams` (if used): `List<Object?> get props => [];` — never `throw UnimplementedError()`.

### Use Cases
One class per use case, single public `call()` method, depends only on the repository interface.  
Use `Future<Either<Failure, T>>` only when the use case touches I/O (datasource, network). Pure in-memory logic stays sync `Either<Failure, T>`.

### Cross-feature coupling
Features must not import from each other. If two features need the same small utility (e.g. MIDI → Note conversion), duplicate it. Shared pure utilities belong in `core/`.

### Dependency Injection (get_it)
```dart
// repositories and datasources are stateless → lazySingleton
sl.registerLazySingleton<MyRepository>(() => MyRepositoryImpl(dataSource: sl()));
sl.registerLazySingleton<MyDataSource>(() => MyDataSourceImpl());
// use cases may be factory (they are lightweight and stateless per call)
sl.registerFactory(() => MyUsecase(repository: sl()));
```

`initDependencies()` in `injection_container.dart` is `async` because SharedPreferences requires `await SharedPreferences.getInstance()` before registration. Call it from `main()` before `runApp`.

### Testability of repository implementations
Inject side-effectful dependencies (`generateId`, `now`) as optional function parameters with production defaults. This lets tests pass deterministic values without mocking `DateTime` or `Uuid`:
```dart
SessionRepositoryImpl({
  required SessionLocalDataSource dataSource,
  String Function()? generateId,
  DateTime Function()? now,
}) : generateId = generateId ?? (() => const Uuid().v4()),
     now = now ?? DateTime.now;
```

### File Granularity
Do **not** create a separate file for a single helper function. Co-locate small functions with the widget or class that owns them. Extract to a file only when the function is reused across multiple widgets.

### Utility Classes
Prefer direct getters over abstract-method-then-getter indirection. If a getter has no parameter variant, expose only the getter.

## Testing Rules

- Name the system under test `sut`.
- Structure every test with `//arrange`, `//act`, `//assert` comments.
- Use `group()` to mirror the class and method hierarchy.
- Use `@GenerateMocks([...])` with mockito; run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate mocks after any repository interface change.
- Test files mirror `lib/` paths under `test/`.
- Shared test data lives in `test/test_data/`; fixtures (raw JSON) in `test/fixtures/`.
- For SharedPreferences tests: call `SharedPreferences.setMockInitialValues({})` in `setUp` before `SharedPreferences.getInstance()`.
- For Riverpod notifier tests: use `ProviderContainer` with `overrides` to inject mock use cases.
- `thenAnswer((_) => Future<void>.value())` for void async stubs (not `thenAnswer((_) async {})`).

## Flutter/Dart Version

- Dart SDK: `>=3.7.2 <4.0.0`
- Flutter: `>=3.18.0`
