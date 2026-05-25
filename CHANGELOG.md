## 1.0.3

- **Package renamed** from `twafok_cli` to `essam_cli`
- **New executable:** the CLI command is now `essam` (previously `twafok`)
- Update all internal help text and usage examples to use the `essam` executable
- Improve `pubspec.yaml` description for better pub.dev discoverability
- Add `gen-barrel` alias to the `generate_paths` help output
- Add `.pubignore` to exclude the legacy `bin/twafok_cli.dart` file from the published package

## 1.0.2

- Refactor `GeneratePathsCommand` with a cleaner, more robust implementation
- Barrel file now automatically exports `package:twafok_shared/twafok_shared.dart` as the shared core dependency
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
- Add TwafokConfig for centralized app settings
- Add CacheHelper integration
- Improve theme management
- Add API shortcuts (get, post, put, patch, delete)

## 1.0.0

- Initial release
- Basic widgets and utilities
- Theme support