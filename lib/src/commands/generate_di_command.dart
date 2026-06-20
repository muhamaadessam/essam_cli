import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';

class GenerateDiCommand {
  void run(List<String> arguments, {String? workingDirectory}) async {
    final parser = ArgParser()
      ..addOption('package',
          abbr: 'p', help: 'Package name', defaultsTo: 'essam')
      ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false);

    try {
      final results = parser.parse(arguments);

      if (results['help'] == true) {
        _printHelp();
        return;
      }

      final args = results.rest;
      final workDir = workingDirectory ?? Directory.current.path;
      final packageName = results['package'] as String;

      // Get feature path
      String featurePath;
      if (args.isNotEmpty) {
        featurePath = args[0];
      } else {
        // Auto-detect current feature
        final autoPath = await _findFeaturePath(workDir);
        if (autoPath != null) {
          featurePath = autoPath;
          print(' 📍 Auto-detected feature path: $featurePath');
        } else {
          print(' ❌ Feature path is required');
          print(' 👉 Example: essam generate_di lib/features/Profile');
          exit(1);
        }
      }

      final absoluteFeaturePath = path.isAbsolute(featurePath)
          ? featurePath
          : path.join(workDir, featurePath);

      // Check if path exists
      if (!await Directory(absoluteFeaturePath).exists()) {
        print(' ❌ Path does not exist: $absoluteFeaturePath');
        exit(1);
      }

      final rawName = path.basename(absoluteFeaturePath);
      final featureName = _toSnakeCase(rawName);
      final diFile = path.join(absoluteFeaturePath, '${featureName}_di.dart');

      print('');
      print(' 🔧 Generating DI file: ${path.basename(diFile)}');
      print(' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Collect all classes
      final useCaseClasses = <String>[];
      final cubitClasses = <String>[];
      final dataSourceClasses = <String>[];
      final repoClasses = <String>[];

      await _collectClasses(absoluteFeaturePath, useCaseClasses, cubitClasses,
          dataSourceClasses, repoClasses);

      // Generate DI file
      await _generateDiFile(
          diFile,
          absoluteFeaturePath,
          featureName,
          packageName,
          useCaseClasses,
          cubitClasses,
          dataSourceClasses,
          repoClasses,
          rawName);

      print('');
      print(' ✅ DI generation completed!');
    } catch (e) {
      print(' ❌ Error: $e');
      exit(1);
    }
  }

  Future<void> _collectClasses(String featurePath, List<String> useCases,
      List<String> cubits, List<String> dataSources, List<String> repos) async {
    final files = Directory(featurePath)
        .list(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.dart'));

    await for (var file in files) {
      final filename = path.basename(file.path);

      // Skip generated files
      if (filename.contains('_di.dart') ||
          filename.contains('.g.dart') ||
          filename.contains('.freezed.dart') ||
          filename.contains('_state.dart') ||
          filename.startsWith('base_')) {
        continue;
      }

      // Determine type
      if (filename.contains('_use_case.dart')) {
        final prefix = filename.replaceAll('_use_case.dart', '');
        final className = '${_toPascalCase(prefix)}UseCase';
        useCases.add(className);
      } else if (filename.contains('_data_source.dart')) {
        String className = filename.replaceAll('.dart', '');
        className = _toPascalCase(className);
        dataSources.add(className);
      } else if (filename.contains('_repository.dart')) {
        String className = filename.replaceAll('.dart', '');
        className = _toPascalCase(className);
        repos.add(className);
      } else if (filename.contains('_cubit.dart') ||
          filename.contains('_bloc.dart')) {
        String className = filename.replaceAll('.dart', '');
        className = _toPascalCase(className);
        cubits.add(className);
      }
    }
  }

  Future<void> _generateDiFile(
      String diFile,
      String featurePath,
      String featureName,
      String packageName,
      List<String> useCases,
      List<String> cubits,
      List<String> dataSources,
      List<String> repos,
      String rawName) async {
    final content = StringBuffer();

    content.writeln('// GENERATED FILE - DO NOT EDIT');
    content.writeln();
    content.writeln("import 'package:get_it/get_it.dart';");
    content.writeln();

    // Import the feature barrel file
    content.writeln("import '$featureName.dart';");
    content.writeln();
    content.writeln('final di = GetIt.instance;');
    content.writeln();

    final pascalName = _toPascalCase(rawName);
    final diClassName = '${pascalName}DI';

    content.writeln('class $diClassName {');
    content.writeln('  $diClassName() {');
    content.writeln('    call();');
    content.writeln('  }');
    content.writeln();
    content.writeln('  void call() {');
    content.writeln('    di');

    // Register DataSources
    for (var ds in dataSources) {
      final base = 'Base$ds';
      content.writeln('      ..registerLazySingleton<$base>(() => $ds())');
    }

    // Register Repositories
    for (var repo in repos) {
      final base = 'Base$repo';
      content
          .writeln('      ..registerLazySingleton<$base>(() => $repo(di()))');
    }

    // Register UseCases
    for (var uc in useCases) {
      content.writeln('      ..registerLazySingleton(() => $uc(di()))');
    }

    // Register Cubits
    for (var cubit in cubits) {
      content.write('      ..registerFactory(() => $cubit(');
      if (useCases.isNotEmpty) {
        for (var i = 0; i < useCases.length; i++) {
          if (i > 0) content.write(', ');
          content.write('di()');
        }
      }
      content.writeln('))');
    }

    content.writeln('      ;');
    content.writeln('  }');
    content.writeln('}');

    await File(diFile).writeAsString(content.toString());
    print(' ✅ Generated: ${path.basename(diFile)}');
  }

  Future<String?> _findFeaturePath(String currentDir) async {
    final domainDir = Directory(path.join(currentDir, 'domain'));
    final dataDir = Directory(path.join(currentDir, 'data'));
    final presentationDir = Directory(path.join(currentDir, 'presentation'));

    if (await domainDir.exists() &&
        await dataDir.exists() &&
        await presentationDir.exists()) {
      return currentDir;
    }

    var dir = Directory(currentDir);
    while (dir.path != '/') {
      final parent = dir.parent;
      final featuresDir = Directory(path.join(parent.path, 'features'));
      if (await featuresDir.exists()) {
        return dir.path;
      }
      dir = dir.parent;
    }

    return null;
  }

  String _toSnakeCase(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (i > 0 &&
          char.toUpperCase() == char &&
          RegExp(r'[A-Z]').hasMatch(char)) {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    }
    return buffer.toString();
  }

  String _toPascalCase(String snakeCase) {
    return snakeCase.split('_').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join();
  }

  void _printHelp() {
    print('''
╔══════════════════════════════════════════════════════════╗
║              Essam CLI - Generate DI Command            ║
╚══════════════════════════════════════════════════════════╝

Usage: 
  essam generate_di <feature_path>
  essam generate_di (from inside feature folder)

Generates dependency injection file (_di.dart) for the feature.

Examples:
  essam generate_di lib/features/Profile
  essam generate_di (when inside lib/features/Profile)
''');
  }
}
