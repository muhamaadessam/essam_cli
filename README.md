# Twafok CLI

> A command-line tool that scaffolds Clean Architecture features for Flutter projects — generate complete features, add use cases, and wire up dependency injection and barrel files automatically.

[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](CHANGELOG.md)

---

## Overview

Building features with Clean Architecture means creating a lot of boilerplate: entities, models, repositories, data sources, use cases, cubits, states, and screens — each in its own layer, each importing the others. **Twafok CLI** does all of that for you with a single command.

It generates a consistent folder structure across the `domain`, `data`, and `presentation` layers, follows the BLoC/Cubit pattern, and keeps your dependency injection and barrel (export) files in sync as your feature grows.

## Features

- **Full feature scaffolding** — one command creates the entire layered structure for a new feature.
- **Incremental use cases** — add new use cases to an existing feature without touching the boilerplate by hand; the tool updates the repository, data source, and cubit for you.
- **Automatic dependency injection** — generates a `*_di.dart` file that registers data sources, repositories, use cases, and cubits with `get_it`.
- **Barrel file generation** — produces a single export file per feature so the rest of your app imports one path instead of many.
- **Auto-formatting** — runs `dart format` and `dart fix --apply` after generation so the output is clean and lint-friendly.
- **Smart path detection** — most commands can auto-detect the current feature when run from inside its folder.

## Generated Structure

Running a feature creation command produces the following layout under `lib/features/<feature_name>/`:

```
lib/features/<feature_name>/
├── data/
│   ├── data_sources/      # Remote data source (Dio-based)
│   ├── models/            # Model extending the domain entity
│   └── repositories/      # Repository implementation
├── domain/
│   ├── entities/          # Equatable entity
│   ├── repositories/      # Abstract base repository
│   └── use_cases/         # Use case + Request/Response classes
├── presentation/
│   ├── controllers/       # Cubit + State
│   ├── screens/           # Screen widget
│   └── widgets/           # Feature-specific widgets
├── <feature_name>.dart    # Barrel file (auto-generated exports)
└── <feature_name>_di.dart # Dependency injection (auto-generated)
```

## Installation

Twafok CLI is a Dart command-line application. You need the [Dart SDK](https://dart.dev/get-dart) (version 3.0 or newer) installed.

### 1. Clone the repository

```bash
git clone https://github.com/muhamaadessam/twafok_cli.git
cd twafok_cli
```

### 2. Install dependencies

```bash
dart pub get
```

### 3. Activate the tool globally

```bash
dart pub global activate --source path .
```

This registers the `twafok` executable so you can run it from any Flutter project directory.

> **Note:** Make sure Dart's `pub` global bin directory is on your `PATH`. On Windows it is typically `%LOCALAPPDATA%\Pub\Cache\bin`; on macOS/Linux it is `$HOME/.pub-cache/bin`.

Alternatively, you can run the tool directly without activating it:

```bash
dart run bin/twafok_cli.dart <command> [arguments]
```

## Usage

Run all commands from the **root of your Flutter project**.

```
twafok_cli <command> [arguments] [options]
```

### Commands

| Command | Aliases | Description |
| --- | --- | --- |
| `create_feature` | `create`, `cr` | Create a complete feature with all layers |
| `add_usecase` | `add`, `add-use-case` | Add a new use case to an existing feature |
| `generate_di` | `gen-di` | (Re)generate the dependency injection file |
| `generate_paths` | `gen-paths`, `gen-barrel` | (Re)generate the barrel/export file |
| `help` | `--help`, `-h` | Show usage information |

### Options

| Option | Abbreviation | Description | Default |
| --- | --- | --- | --- |
| `--package` | `-p` | Package name used in generated imports | `twafok` |
| `--help` | `-h` | Show help for the command | — |

> The `generate_paths` command reads the package name directly from your project's `pubspec.yaml`, so you usually don't need to pass `--package` to it.

## Examples

### Create a new feature

```bash
twafok_cli create_feature Profile
twafok_cli create Authentication        # using the shortcut alias
```

This creates the full `lib/features/Profile/` structure, generates the DI and barrel files, then formats the project.

### Add a use case to an existing feature

Provide the feature path and the action name:

```bash
twafok_cli add_usecase lib/features/Profile update_profile
```

Or run it from **inside** the feature folder and let the tool detect the path:

```bash
cd lib/features/Profile
twafok_cli add update_profile
```

The tool generates the new use case file (with `Request` and `Response` classes) and updates the base repository, repository implementation, remote data source, and cubit accordingly.

### Regenerate dependency injection

```bash
twafok_cli generate_di lib/features/Profile
twafok_cli gen-di                       # auto-detects the feature when run inside its folder
```

### Regenerate the barrel file

```bash
twafok_cli generate_paths lib/features/Profile
twafok_cli gen-paths                    # auto-detects the feature when run inside its folder
```

## How It Works

Twafok CLI is organized into a few clear layers:

- **`bin/twafok_cli.dart`** — the entry point. It parses the top-level command and delegates to the matching command handler.
- **`lib/commands/`** — one class per command (`CreateFeatureCommand`, `AddUsecaseCommand`, `GenerateDiCommand`, `GeneratePathsCommand`). Each parses its own arguments and orchestrates the work.
- **`lib/generators/`** — focused generators that create or update individual artifacts (use case, cubit, data source, repository).
- **`lib/services/`** — shared helpers: `NamingUtils` handles all the naming conventions (snake_case, PascalCase, class names), and `FileUtils` handles file lookup and code injection.
- **`lib/templates/`** — code templates used during generation.

When you add a use case, the generators don't rewrite existing files from scratch — they insert the new method signatures and fields before the closing brace of the relevant class, so your existing code is preserved.

## Generated Code Conventions

The generated code assumes your project provides a small set of shared base classes (commonly placed in a `core` library), including:

- `BaseUseCase<Response, Request>` — base class for use cases
- `BaseCubit<State>` and `BaseState` — base classes for state management
- `BaseView<Cubit, State>` — base widget for screens
- `Failure` / `ServerFailure` — error types used with `Either` from `dartz`
- `DioHelper` — a wrapper around `dio` for network calls

Generated files are marked with a `// GENERATED FILE - DO NOT EDIT` header. Files that you are expected to customize (such as `Request` field definitions and API endpoints) are flagged in the command's "Next steps" output.

## Dependencies

| Package | Purpose |
| --- | --- |
| [`args`](https://pub.dev/packages/args) | Parses command-line arguments and options |
| [`path`](https://pub.dev/packages/path) | Cross-platform file path manipulation |
| [`io`](https://pub.dev/packages/io) | I/O utilities for command-line apps |

## Roadmap

Some areas are still in progress or planned (a few modules in the codebase are currently commented out):

- Configurable templates so teams can adapt the generated code to their own base classes.
- A `--dry-run` flag to preview generated files before writing them.
- Unit tests covering the generators and naming utilities.

Contributions and ideas are welcome.

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/my-improvement`.
3. Make your changes and run `dart format .` and `dart analyze`.
4. Commit and push, then open a Pull Request.

Please open an [issue](https://github.com/muhamaadessam/twafok_cli/issues) first for larger changes so we can discuss the approach.

## License

This project is licensed under the [MIT License](LICENSE).

## Author

**Mohamed Essam** — [@muhamaadessam](https://github.com/muhamaadessam)