## 1.0.5

- **Fix `essam_shared` references:** Updated generated barrel files and documentation to use the new `essam_shared` package instead of the legacy `essam_shared`.
- **Clean up unused imports:** Removed unused imports (`flutter/material.dart`, `dio.dart`, `flutter_bloc.dart`) from generated files (data sources, states, cubits, views) to prevent lint warnings.
- **Format code:** Applied dart formatter to `generate_paths_command.dart`.

## 1.0.4

- **Fix UseCase injection paths:** Updated `add_usecase` generators to correctly search in `repositories` and `data_sources` directories instead of singular folder names.
- **Fix Cubit Generator Regex:** Fixed regex pattern to correctly identify and inject into `BaseCubit` classes instead of only standard `Cubit`.
- **Fix Trailing Comma Syntax Error:** Prevented invalid Dart syntax and `dart format` failures by correctly handling trailing commas when injecting use cases into Cubit constructors.
- **Match Feature Scaffolding Boilerplate:** 
  - `Request` models now default to `id` only.
  - Action methods now use `PageState` (`PageState.loading`, `PageState.success`, `PageState.errorWithSnackBar`) matching `create_feature` standards.
- **Auto-Fix Support:** `add_usecase` command now automatically runs `dart fix --apply` after generating and formatting files.

## 1.0.3

- **Package renamed** from `essam_cli` to `essam_cli`
- **New executable:** the CLI command is now `essam` (previously `essam`)
- Update all internal help text and usage examples to use the `essam` executable
- Improve `pubspec.yaml` description for better pub.dev discoverability
- Add `gen-barrel` alias to the `generate_paths` help output
- Add `.pubignore` to exclude the legacy `bin/essam_cli.dart` file from the published package

## 1.0.2

- Refactor `GeneratePathsCommand` with a cleaner, more robust implementation
- Barrel file now automatically exports `package:essam_shared/essam_shared.dart` as the shared core dependency
- Package name is now auto-detected from `pubspec.yaml` (walks up parent directories) instead of relying on the `--package` flag
- Add `gen-barrel` as an additional alias for the `generate_paths` command
- Fix inconsistent executable name in help output
- Remove stale commented-out code from `GeneratePathsCommand`

## 1.0.1+1

- Replace `Either<Failure, T>` with `Result<T>` in repository, use case, and data source templates
- Simplify `DataSource` implementation by utilizing `DioHelper.getData` with the new `fromJson` parameter
- Refine regex patterns and formatting in `CubitGenerator` and `DataSourceGenerator`
- Update device streaming configuration with Galaxy A32 options

## 1.0.1

- Add DioConfig for flexible API configuration
- Add EssamConfig for centralized app settings
- Add CacheHelper integration
- Improve theme management
- Add API shortcuts (get, post, put, patch, delete)

## 1.0.0

- Initial release
- Basic widgets and utilities
- Theme support