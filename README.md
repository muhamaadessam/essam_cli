# Essam CLI

> A Dart command-line tool that scaffolds complete **Clean Architecture** features for Flutter projects — generate features, add use cases, and keep your dependency injection and barrel files in sync, automatically.

[![pub.dev](https://img.shields.io/pub/v/essam_cli.svg)](https://pub.dev/packages/essam_cli)
[![Dart SDK](https://img.shields.io/badge/Dart-≥3.0.0-0175C2?logo=dart&logoColor=white)](https://dart.dev/get-dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Overview

Building features with Clean Architecture means creating a lot of boilerplate: entities, models, repositories, data sources, use cases, cubits, states, and screens — each in its own layer, each importing the others. **Essam CLI** does all of that for you with a single command.

It generates a consistent folder structure across the `domain`, `data`, and `presentation` layers, follows the BLoC/Cubit pattern, and keeps your dependency injection and barrel (export) files in sync as your feature grows.

> **Migrating from `twafok_cli`?** Run `dart pub global activate essam_cli` and replace the `twafok` command with `essam`. All commands and flags are identical.

---

## Features

- **Full feature scaffolding** — one command creates the entire layered structure for a new feature.
- **Incremental use cases** — add new use cases to an existing feature without touching any boilerplate by hand; the tool updates the repository, data source, and cubit for you.
- **Automatic dependency injection** — generates a `*_di.dart` file that registers data sources, repositories, use cases, and cubits with `get_it`.
- **Barrel file generation** — produces a single export file per feature so the rest of your app imports one path instead of many. The package name is read automatically from your project's `pubspec.yaml`.
- **Auto-formatting** — runs `dart format` and `dart fix --apply` after generation so the output is immediately clean and lint-friendly.
- **Smart path detection** — all commands can auto-detect the current feature when run from inside its directory.

---

## Generated Structure

Running `essam create <FeatureName>` produces the following layout under `lib/features/<feature_name>/`:

```
lib/features/<feature_name>/
├── data/
│   ├── data_sources/        # Remote data source (Dio-based)
│   ├── models/              # Model extending the domain entity
│   └── repositories/        # Repository implementation
├── domain/
│   ├── entities/            # Equatable entity
│   ├── repositories/        # Abstract base repository
│   └── use_cases/           # Use case + Request/Response classes
├── presentation/
│   ├── controllers/         # Cubit + State
│   ├── screens/             # Screen widget
│   └── widgets/             # Feature-specific widgets
├── <feature_name>.dart      # Barrel file (auto-generated exports)
└── <feature_name>_di.dart   # Dependency injection (auto-generated)
```

---

## Installation

Essam CLI requires the [Dart SDK](https://dart.dev/get-dart) **≥ 3.0.0**.

### From pub.dev (recommended)

```bash
dart pub global activate essam_cli
```

This registers the `essam` executable globally so you can run it from any Flutter project directory.

> **Note:** Make sure Dart's pub-cache `bin` directory is on your `PATH`.
> - **macOS / Linux:** `export PATH="$PATH:$HOME/.pub-cache/bin"`
> - **Windows:** `%LOCALAPPDATA%\Pub\Cache\bin`

### From source

```bash
git clone https://github.com/muhamaadessam/essam_cli.git
cd essam_cli
dart pub get
dart pub global activate --source path .
```

---

## Usage

Run all commands from the **root of your Flutter project**.

```
essam <command> [arguments] [options]
```

### Commands

| Command | Aliases | Description |
|---|---|---|
| `create_feature` | `create`, `cr` | Create a complete feature with all layers |
| `add_usecase` | `add`, `add-use-case` | Add a new use case to an existing feature |
| `generate_di` | `gen-di` | (Re)generate the dependency injection file |
| `generate_paths` | `gen-paths`, `gen-barrel` | (Re)generate the barrel/export file |
| `help` | `--help`, `-h` | Show usage information |

### Options

| Option | Short | Description | Default |
|---|---|---|---|
| `--package` | `-p` | Package name used in generated imports | `essam` |
| `--help` | `-h` | Show help for the command | — |

> **Note:** `generate_paths` reads the package name directly from your project's `pubspec.yaml`, so you never need to pass `--package` for that command.

---

## Examples

### Create a new feature

```bash
essam create Profile
essam create_feature Authentication   # full command name
essam cr Orders                       # short alias
```

This creates the full `lib/features/Profile/` directory structure, generates all layer files, produces the `profile_di.dart` DI file and `profile.dart` barrel file, and then formats the project.

**Console output:**

```
🚀 Creating feature: Profile
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 Creating feature structure...
  ✅ Created: .../lib/features/Profile/data/data_sources
  ✅ Created: .../lib/features/Profile/data/models
  ✅ Created: .../lib/features/Profile/data/repositories
  ✅ Created: .../lib/features/Profile/domain/entities
  ✅ Created: .../lib/features/Profile/domain/repositories
  ✅ Created: .../lib/features/Profile/domain/use_cases
  ✅ Created: .../lib/features/Profile/presentation/controllers
  ✅ Created: .../lib/features/Profile/presentation/screens
  ✅ Created: .../lib/features/Profile/presentation/widgets
📝 Generating entity and model...
  ✅ Entity created: profile_entity.dart
  ✅ Model created: profile_model.dart
  ✅ Base repository created: base_profile_repository.dart
  ✅ Repository created: profile_repository.dart
  ✅ Remote data source created: profile_remote_data_source.dart
  ✅ UseCase created: get_profile_use_case.dart
  ✅ Cubit and State created
  ✅ Screen created: profile_screen.dart

🔄 Generating DI and barrel files...
 ✅ Generated: profile_di.dart
 ✅ Generated: profile.dart

🎨 Formatting project code...
 ✅ Project formatted successfully

🔧 Running dart fix --apply...
 ✅ Dart fix completed successfully

🎉 Feature 'Profile' created successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Feature location: .../lib/features/Profile

📝 Next steps:
   1. Add your business logic to the cubit
   2. Update the API endpoints in remote_data_source
   3. Add more use cases using: essam add lib/features/Profile <action>
```

---

### Add a use case to an existing feature

Provide the feature path and the action name:

```bash
essam add_usecase lib/features/Profile update_profile
```

Or run it from **inside** the feature folder — the path is auto-detected:

```bash
cd lib/features/Profile
essam add update_profile
```

This generates the new use case file (with `Request` and `Response` classes) and updates the abstract repository, repository implementation, remote data source, and cubit to include the new method — without touching any existing logic.

**Console output:**

```
🚀 Essam CLI - Adding UseCase
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   UseCase     : UpdateProfileUseCase
   Feature     : Profile
   Path        : .../lib/features/Profile
   Package     : my_app

📝 Generating files...
  ✅ UseCase file generated
  ✅ Base repository updated
  ✅ Repository implementation updated
  ✅ Remote data source updated
  ✅ Cubit updated

✨ Success!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ UseCase 'UpdateProfileUseCase' added to 'Profile' feature

📝 Next steps:
   1. Update UpdateProfileRequest fields to match your API
   2. Update the endpoint in RemoteDataSource
   3. Call updateProfile() from UI
```

---

### Regenerate the dependency injection file

```bash
essam generate_di lib/features/Profile
essam gen-di                            # auto-detects the feature when run inside its folder
```

Scans the feature directory for data sources, repositories, use cases, and cubits, then generates a `<feature_name>_di.dart` file that wires them all up with `get_it`.

---

### Regenerate the barrel file

```bash
essam generate_paths lib/features/Profile
essam gen-barrel                         # auto-detects the feature when run inside its folder
```

Walks the feature directory and produces a single `<feature_name>.dart` file that exports every Dart file in the feature (excluding state files, DI files, and code-generated files such as `.g.dart` and `.freezed.dart`). The package name is read automatically from `pubspec.yaml`.

---

## Generated Code Conventions

The generated code assumes your project provides a small set of shared base classes — typically provided by the `essam_shared` package or your own `core` library:

| Base class | Purpose |
|---|---|
| `BaseUseCase<Response, Request>` | Base class for use cases |
| `BaseCubit<State>` | Base cubit class |
| `BaseState` / `PageState` | State management primitives |
| `BaseView<Cubit, State>` | Base widget for feature screens |
| `Failure` / `ServerFailure` | Error types used with `Result<T>` |
| `DioHelper` | Network call wrapper (around `dio`) |

Generated files are marked with a `// GENERATED FILE - DO NOT EDIT` header. Files that you are expected to customize — such as `Request` field definitions, API endpoints, and entity fields — are flagged in the command's **Next steps** output.

---

## How It Works

```
bin/essam_cli.dart           Entry point — parses the top-level command and delegates
lib/commands/                One class per command; each parses its own arguments
lib/generators/              Focused generators that create or patch individual artifacts
lib/services/                Shared helpers (NamingUtils, FileUtils, InjectionService)
lib/templates/               Code templates used during generation
```

When you add a use case, the generators insert the new method signatures and field declarations before the closing brace of the relevant class, preserving all your existing code.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| [`args`](https://pub.dev/packages/args) | `^2.4.0` | Command-line argument parsing |
| [`path`](https://pub.dev/packages/path) | `^1.9.0` | Cross-platform file path manipulation |
| [`io`](https://pub.dev/packages/io) | `^1.0.4` | I/O utilities for CLI apps |

---

## Troubleshooting

**`essam: command not found`**
The pub-cache `bin` directory is not on your `PATH`. Add the following to your shell profile:
```bash
export PATH="$PATH:$HOME/.pub-cache/bin"   # macOS / Linux
```
On Windows, add `%LOCALAPPDATA%\Pub\Cache\bin` to your system `PATH`.

**Feature already exists error**
The tool exits with an error if the feature directory already exists. Remove or rename the existing directory before running `essam create` again.

**Auto-detect fails for `add` / `gen-di` / `gen-barrel`**
These commands detect your feature by looking for `domain/`, `data/`, and `presentation/` sibling directories. Run them from inside the feature folder (e.g. `lib/features/Profile`) or pass the path explicitly.

---

## Roadmap

- Configurable templates so teams can adapt the generated code to their own base classes.
- A `--dry-run` flag to preview generated files before writing them.
- Unit tests covering the generators and naming utilities.
- Interactive prompts for field definitions during feature creation.

---

## Contributing

1. Fork the repository on [GitHub](https://github.com/muhamaadessam/essam_cli).
2. Create a feature branch: `git checkout -b feature/my-improvement`.
3. Make your changes and run `dart format .` and `dart analyze`.
4. Commit and push your branch, then open a Pull Request.

Please open an [issue](https://github.com/muhamaadessam/essam_cli/issues) first for larger changes so we can discuss the approach before you invest time in implementation.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Author

**Mohamed Essam** — [@muhamaadessam](https://github.com/muhamaadessam)