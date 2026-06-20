import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import '../generators/cubit_generator.dart';
import '../generators/datasource_generator.dart';
import '../generators/repository_generator.dart';
import '../generators/usecase_generator.dart';
import '../services/naming_service.dart';
import 'generate_di_command.dart';
import 'generate_paths_command.dart';

class AddUsecaseCommand {
  void run(List<String> arguments, {String? workingDirectory}) async {
    final parser = ArgParser()
      ..addOption('package',
          abbr: 'p', help: 'Package name', defaultsTo: 'essam')
      ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false);

    try {
      final results = parser.parse(arguments);

      if (results['help'] == true) {
        _printHelp(parser);
        return;
      }

      final args = results.rest;
      final workDir = workingDirectory ?? Directory.current.path;

      // Remove 'add_usecase' from args if it's the first argument
      List<String> cleanArgs = List.from(args);
      if (cleanArgs.isNotEmpty && cleanArgs[0] == 'add_usecase') {
        cleanArgs.removeAt(0);
      }

      String featurePath;
      String usecaseAction;
      final packageName = results['package'] as String;

      // Case 1: User provided both feature path and action
      if (cleanArgs.length >= 2) {
        featurePath = cleanArgs[0];
        usecaseAction = cleanArgs[1];
      }
      // Case 2: User provided only action (try to auto-detect feature path)
      else if (cleanArgs.length == 1) {
        usecaseAction = cleanArgs[0];
        final autoPath = await _findFeaturePath(workDir);
        if (autoPath != null) {
          featurePath = autoPath;
          print('');
          print('📍 Auto-detected feature path: $featurePath');
        } else {
          print('❌ Could not auto-detect feature path');
          print('💡 Please run this command from inside a feature folder');
          print(
              '   Or provide the full path: essam add_usecase lib/features/FeatureName action_name');
          exit(1);
        }
      }
      // Case 3: No arguments
      else {
        print('❌ Missing usecase action');
        print('');
        print('Usage:');
        print('  essam add_usecase <feature_path> <usecase_action>');
        print(
            '  essam add_usecase <usecase_action> (from inside feature folder)');
        exit(1);
      }

      // Build absolute path
      final absoluteFeaturePath = path.isAbsolute(featurePath)
          ? featurePath
          : path.join(workDir, featurePath);

      print('');
      print('📂 Working directory: $workDir');
      print('📁 Feature path: $absoluteFeaturePath');
      print('🎯 UseCase action: $usecaseAction');

      // Validate paths
      final featureDir = Directory(absoluteFeaturePath);
      if (!await featureDir.exists()) {
        print('❌ Feature path does not exist: $absoluteFeaturePath');
        print('');
        print('💡 Make sure:');
        print(
            '   1. You are running this command from inside a feature folder');
        print(
            '   2. Or provide the full path: essam add_usecase lib/features/buffet action_name');
        exit(1);
      }

      final rawFeature = path.basename(absoluteFeaturePath);
      final naming = NamingUtils(rawFeature, usecaseAction);

      print('');
      print('🚀 Essam CLI - Adding UseCase');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('   UseCase     : ${naming.usecaseClass}');
      print('   Feature     : ${naming.featureCap}');
      print('   Path        : $absoluteFeaturePath');
      print('   Package     : $packageName');
      print('');

      // 1. Generate UseCase file
      print('📝 Generating files...');
      final usecaseGen = UsecaseGenerator(absoluteFeaturePath, naming);
      await usecaseGen.generate();

      // 2. Update BaseRepository
      final repoGen = RepositoryGenerator(absoluteFeaturePath, naming);
      await repoGen.updateBaseRepository();

      // 3. Update Repository impl
      await repoGen.updateRepositoryImpl();

      // 4. Update DataSource
      final dsGen = DataSourceGenerator(absoluteFeaturePath, naming);
      await dsGen.updateDataSource();

      // 5. Update Cubit
      final cubitGen = CubitGenerator(absoluteFeaturePath, naming);
      await cubitGen.updateCubit();

      // 6 & 7. Regenerate DI and barrel files (optional)
      print('');
      print('🔄 Running additional scripts...');
      // Generate DI
      final diCommand = GenerateDiCommand();
      diCommand.run([absoluteFeaturePath], workingDirectory: workDir);

      // Generate Paths/Barrel
      final pathsCommand = GeneratePathsCommand();
      pathsCommand.run([absoluteFeaturePath], workingDirectory: workDir);

      // 8. Format the project
      await _formatProject(workDir);

      // 9. Run dart fix
      await _runDartFix(workDir);

      print('');
      print('✨ Success!');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print(
          '✅ UseCase \'${naming.usecaseClass}\' added to \'${naming.featureCap}\' feature');
      print('');
      print('📝 Next steps:');
      print('   1. Update ${naming.requestClass} fields to match your API');
      print('   2. Update the endpoint in RemoteDataSource');
      print('   3. Call ${naming.actionCamel}${naming.featureCap}() from UI');
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      if (e is! ArgumentError) {
        print('Stack trace: $stackTrace');
      }
      exit(1);
    }
  }

  Future<String?> _findFeaturePath(String currentDir) async {
    // Check if current directory is a feature folder
    final domainDir = Directory(path.join(currentDir, 'domain'));
    final dataDir = Directory(path.join(currentDir, 'data'));
    final presentationDir = Directory(path.join(currentDir, 'presentation'));

    if (await domainDir.exists() &&
        await dataDir.exists() &&
        await presentationDir.exists()) {
      return currentDir;
    }

    // Check if we're inside a feature subfolder
    var dir = Directory(currentDir);
    while (dir.path != '/') {
      final parent = dir.parent;
      final featuresDir = Directory(path.join(parent.path, 'features'));
      if (await featuresDir.exists()) {
        // We're inside a feature folder
        return dir.path;
      }
      dir = dir.parent;
    }

    return null;
  }

  Future<void> _formatProject(String workDir) async {
    print('   🎨 Formatting project code...');
    try {
      final result = await Process.run(
        'dart',
        ['format', '.'],
        workingDirectory: workDir,
        runInShell: true,
      );
      if (result.exitCode == 0) {
        print('   ✅ Project formatted successfully');
      } else {
        print('   ⚠️ Formatting had issues');
      }
    } catch (e) {
      print('   ⚠️ Could not format project: $e');
    }
  }

  Future<void> _runDartFix(String workDir) async {
    print('   🔧 Running dart fix --apply...');
    try {
      final result = await Process.run(
        'dart',
        ['fix', '--apply'],
        workingDirectory: workDir,
        runInShell: true,
      );
      if (result.exitCode == 0) {
        print('   ✅ Dart fix completed successfully');
      } else {
        print('   ⚠️ Dart fix had issues: ${result.stderr}');
      }
    } catch (e) {
      print('   ⚠️ Could not run dart fix: $e');
    }
  }

  void _printHelp(ArgParser parser) {
    print('''
╔══════════════════════════════════════════════════════════╗
║              Essam CLI - Add UseCase Command            ║
╚══════════════════════════════════════════════════════════╝

Usage: 
  essam add_usecase <feature_path> <usecase_action>
  essam add_usecase <usecase_action> (from inside feature folder)

Examples:
  essam add_usecase lib/features/Profile update_profile
  essam add_usecase update_profile (when inside lib/features/Profile)
''');
  }
}
