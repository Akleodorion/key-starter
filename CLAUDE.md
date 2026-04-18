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

State management: **Riverpod** (`StateNotifier` + sealed state classes).  
DI: **get_it** (`registerLazySingleton` for stateless services like repositories and datasources; `registerFactory` only when a new instance is genuinely needed per call).  
Error handling: **dartz** `Either<Failure, T>` — never use `!` on an `Either`, it is never nullable.  
Value equality: **equatable** on all entities and state classes.

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

### File Granularity
Do **not** create a separate file for a single helper function. Co-locate small functions with the widget or class that owns them. Extract to a file only when the function is reused across multiple widgets.

### Dependency Injection (get_it)
```dart
// repositories and datasources are stateless → lazySingleton
sl.registerLazySingleton<MyRepository>(() => MyRepositoryImpl(dataSource: sl()));
sl.registerLazySingleton<MyDataSource>(() => MyDataSourceImpl());
// use cases may be factory (they are lightweight and stateless per call)
sl.registerFactory(() => MyUsecase(repository: sl()));
```

### Utility Classes
Prefer direct getters over abstract-method-then-getter indirection. If a getter has no parameter variant, expose only the getter.

## Testing Rules

- Name the system under test `sut`.
- Structure every test with `//arrange`, `//act`, `//assert` comments.
- Use `group()` to mirror the class and method hierarchy.
- Use `@GenerateMocks([...])` with mockito; run `flutter pub run build_runner build` to regenerate mocks.
- Test files mirror `lib/` paths under `test/`.
- Shared test data lives in `test/test_data/`; fixtures (raw JSON) in `test/fixtures/`.

## Flutter/Dart Version

- Dart SDK: `>=3.7.2 <4.0.0`
- Flutter: `>=3.18.0`
