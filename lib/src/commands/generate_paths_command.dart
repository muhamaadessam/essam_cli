// import 'dart:io';
// import 'package:path/path.dart' as path;
// import 'package:args/args.dart';
//
// class GeneratePathsCommand {
//   void run(List<String> arguments, {String? workingDirectory}) async {
//     final parser = ArgParser()
//       ..addOption('package',
//           abbr: 'p', help: 'Package name', defaultsTo: 'essam')
//       ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false);
//
//     try {
//       final results = parser.parse(arguments);
//
//       if (results['help'] == true) {
//         _printHelp();
//         return;
//       }
//
//       final args = results.rest;
//       final workDir = workingDirectory ?? Directory.current.path;
//       final packageName = results['package'] as String;
//
//       // Get feature path
//       String featurePath;
//       if (args.isNotEmpty) {
//         featurePath = args[0];
//       } else {
//         final autoPath = await _findFeaturePath(workDir);
//         if (autoPath != null) {
//           featurePath = autoPath;
//           print(' 📍 Auto-detected feature path: $featurePath');
//         } else {
//           print(' ❌ Feature path is required');
//           print(' 👉 Example: essam generate_paths lib/features/Profile');
//           exit(1);
//         }
//       }
//
//       final absoluteFeaturePath = path.isAbsolute(featurePath)
//           ? featurePath
//           : path.join(workDir, featurePath);
//
//       if (!await Directory(absoluteFeaturePath).exists()) {
//         print(' ❌ Path does not exist: $absoluteFeaturePath');
//         exit(1);
//       }
//
//       final rawName = path.basename(absoluteFeaturePath);
//       final featureName = _toSnakeCase(rawName);
//       final outputFile = path.join(absoluteFeaturePath, '$featureName.dart');
//
//       print(' ');
//       print(' 🔧 Generating barrel file: ${path.basename(outputFile)}');
//       print(' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
//
//       await _generateBarrelFile(outputFile, absoluteFeaturePath, featureName, packageName, rawName);
//
//       print('');
//       print(' ✅ Barrel file generation completed!');
//
//     } catch (e) {
//       print(' ❌ Error: $e');
//       exit(1);
//     }
//   }
//
//   Future<void> _generateBarrelFile(String outputFile, String featurePath,
//       String featureName, String packageName,
//       String rawName) async {
//     final content = StringBuffer();
//
//     content.writeln('// GENERATED FILE - DO NOT EDIT');
//     content.writeln("export 'package:essam/core/core.dart';");
//     content.writeln();
//
//     // Add commented full import line
//     final relativePath = featurePath.substring(featurePath.indexOf('lib/'));
//     content.writeln("// import 'package:$packageName/$relativePath/$featureName.dart';");
//     content.writeln();
//
//     // Special case for lib/Core
//     if (featurePath.contains('lib/Core') || featurePath.contains('lib/core')) {
//       content.writeln("export 'package:$packageName/res/assets.dart';");
//       content.writeln();
//     }
//
//     // Collect all dart files (same logic as bash script)
//     final files = Directory(featurePath)
//         .list(recursive: true)
//         .where((entity) => entity is File && entity.path.endsWith('.dart'));
//
//     final exports = <String>[];
//
//     await for (var file in files) {
//       final filename = path.basename(file.path);
//
//       // Skip the main barrel file and generated files
//       if (filename == '$featureName.dart' ||
//           filename.contains('.g.dart') ||
//           filename.contains('_state.dart') ||
//           filename.contains('_di.dart') ||
//           filename.contains('.freezed.dart')) {
//         continue;
//       }
//
//       final relativePath = path.relative(file.path, from: featurePath);
//       exports.add("export '$relativePath';");
//     }
//
//     // Sort exports alphabetically
//     exports.sort();
//
//     for (var export in exports) {
//       content.writeln(export);
//     }
//
//     await File(outputFile).writeAsString(content.toString());
//     print(' ✅ Generated: ${path.basename(outputFile)}');
//     print('   Exported ${exports.length} files');
//   }
//
//   Future<String?> _findFeaturePath(String currentDir) async {
//     final domainDir = Directory(path.join(currentDir, 'domain'));
//     final dataDir = Directory(path.join(currentDir, 'data'));
//     final presentationDir = Directory(path.join(currentDir, 'presentation'));
//
//     if (await domainDir.exists() &&
//         await dataDir.exists() &&
//         await presentationDir.exists()) {
//       return currentDir;
//     }
//
//     var dir = Directory(currentDir);
//     while (dir.path != '/') {
//       final parent = dir.parent;
//       final featuresDir = Directory(path.join(parent.path, 'features'));
//       if (await featuresDir.exists()) {
//         return dir.path;
//       }
//       dir = dir.parent;
//     }
//
//     return null;
//   }
//
//   String _toSnakeCase(String input) {
//     final buffer = StringBuffer();
//     for (var i = 0; i < input.length; i++) {
//       final char = input[i];
//       if (i > 0 && char.toUpperCase() == char && RegExp(r'[A-Z]').hasMatch(char)) {
//         buffer.write('_');
//       }
//       buffer.write(char.toLowerCase());
//     }
//     return buffer.toString();
//   }
//
//   void _printHelp() {
//     print('''
// ╔══════════════════════════════════════════════════════════╗
// ║            Essam CLI - Generate Paths Command           ║
// ╚══════════════════════════════════════════════════════════╝
//
// Usage:
//   essam generate_paths <feature_path>
//   essam generate_paths (from inside feature folder)
//
// Generates barrel file that exports all Dart files in the feature.
//
// Examples:
//   essam generate_paths lib/features/Profile
//   essam generate_paths (when inside lib/features/Profile)
// ''');
//   }
// }

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';

class GeneratePathsCommand {
  void run(List<String> arguments, {String? workingDirectory}) async {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false);

    try {
      final results = parser.parse(arguments);

      if (results['help'] == true) {
        _printHelp();
        return;
      }

      final args = results.rest;
      final workDir = workingDirectory ?? Directory.current.path;

      // Get package name from pubspec.yaml
      final packageName = await _getPackageName(workDir);

      // Get feature path
      String featurePath;
      if (args.isNotEmpty) {
        featurePath = args[0];
      } else {
        final autoPath = await _findFeaturePath(workDir);
        if (autoPath != null) {
          featurePath = autoPath;
          print(' 📍 Auto-detected feature path: $featurePath');
        } else {
          print(' ❌ Feature path is required');
          print(' 👉 Example: essam generate_paths lib/features/Profile');
          exit(1);
        }
      }

      final absoluteFeaturePath = path.isAbsolute(featurePath)
          ? featurePath
          : path.join(workDir, featurePath);

      if (!await Directory(absoluteFeaturePath).exists()) {
        print(' ❌ Path does not exist: $absoluteFeaturePath');
        exit(1);
      }

      final rawName = path.basename(absoluteFeaturePath);
      final featureName = _toSnakeCase(rawName);
      final outputFile = path.join(absoluteFeaturePath, '$featureName.dart');

      print(' ');
      print(' 🔧 Generating barrel file: ${path.basename(outputFile)}');
      print(' ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print(' 📦 Package name: $packageName');

      await _generateBarrelFile(
          outputFile, absoluteFeaturePath, featureName, packageName, rawName);

      print('');
      print(' ✅ Barrel file generation completed!');
    } catch (e) {
      print(' ❌ Error: $e');
      exit(1);
    }
  }

  Future<String> _getPackageName(String workDir) async {
    // Search for pubspec.yaml in current directory or parent directories
    var dir = Directory(workDir);
    while (dir.path != '/') {
      final pubspecFile = File(path.join(dir.path, 'pubspec.yaml'));
      if (await pubspecFile.exists()) {
        try {
          final content = await pubspecFile.readAsString();
          // Extract package name using regex
          final nameRegex = RegExp(r'^name:\s*([^\s]+)', multiLine: true);
          final match = nameRegex.firstMatch(content);
          if (match != null) {
            final packageName = match.group(1);
            print(' 📦 Found package name: $packageName');
            return packageName!;
          }
        } catch (e) {
          print(' ⚠️ Could not parse pubspec.yaml: $e');
        }
      }
      dir = dir.parent;
    }

    // Fallback to default
    print(
        ' ⚠️ Could not find package name in pubspec.yaml, using default: essam');
    return 'essam';
  }

  Future<void> _generateBarrelFile(String outputFile, String featurePath,
      String featureName, String packageName, String rawName) async {
    final content = StringBuffer();

    content.writeln('// GENERATED FILE - DO NOT EDIT');
    content.writeln("export 'package:essam_shared/essam_shared.dart';");
    content.writeln();

    // Add commented full import line with detected package name
    final relativePath = featurePath.substring(featurePath.indexOf('lib/'));
    content.writeln(
        "// import 'package:$packageName/$relativePath/$featureName.dart';");
    content.writeln();

    // Special case for lib/Core
    if (featurePath.contains('lib/Core') || featurePath.contains('lib/core')) {
      content.writeln("export 'package:$packageName/res/assets.dart';");
      content.writeln();
    }

    // Collect all dart files (same logic as bash script)
    final files = Directory(featurePath)
        .list(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.dart'));

    final exports = <String>[];

    await for (var file in files) {
      final filename = path.basename(file.path);

      // Skip the main barrel file and generated files
      if (filename == '$featureName.dart' ||
          filename.contains('.g.dart') ||
          filename.contains('_state.dart') ||
          filename.contains('_di.dart') ||
          filename.contains('.freezed.dart')) {
        continue;
      }

      final relativePath = path.relative(file.path, from: featurePath);
      exports.add("export '$relativePath';");
    }

    // Sort exports alphabetically
    exports.sort();

    for (var export in exports) {
      content.writeln(export);
    }

    await File(outputFile).writeAsString(content.toString());
    print(' ✅ Generated: ${path.basename(outputFile)}');
    print('   Exported ${exports.length} files');
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

  void _printHelp() {
    print('''
╔══════════════════════════════════════════════════════════╗
║            Essam CLI - Generate Paths Command           ║
╚══════════════════════════════════════════════════════════╝

Usage: 
  essam generate_paths <feature_path>
  essam generate_paths (from inside feature folder)

Generates barrel file that exports all Dart files in the feature.

The package name is automatically detected from pubspec.yaml.

Examples:
  essam generate_paths lib/features/Profile
  essam generate_paths (when inside lib/features/Profile)
''');
  }
}
