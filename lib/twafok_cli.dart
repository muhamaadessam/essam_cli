// import 'dart:io';
//
// import 'package:args/args.dart';
// import 'package:path/path.dart' as path;
// import 'package:twafok_cli/services/naming_service.dart';
//
// import 'generators/cubit_generator.dart';
// import 'generators/datasource_generator.dart';
// import 'generators/repository_generator.dart';
// import 'generators/usecase_generator.dart';
//
// class AddUsecaseCLI {
//   void run(List<String> arguments) async {
//     final parser = ArgParser()
//       ..addOption('package',
//           abbr: 'p', help: 'Package name', defaultsTo: 'twafok')
//       ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false);
//
//     try {
//       final results = parser.parse(arguments);
//
//       if (results['help'] == true) {
//         _printHelp(parser);
//         return;
//       }
//
//       final args = results.rest;
//       if (args.length < 2) {
//         _printHelp(parser);
//         exit(1);
//       }
//
//       final featurePath = args[0];
//       final usecaseAction = args[1];
//       final packageName = results['package'] as String;
//
//       // Validate paths
//       if (!await Directory(featurePath).exists()) {
//         print('${results.rest}');
//         print(' Feature path does not exist: $featurePath');
//         exit(1);
//       }
//
//       final rawFeature = path.basename(featurePath);
//       final naming = NamingUtils(rawFeature, usecaseAction);
//
//       print('');
//       print('🚀 Adding UseCase: ${naming.usecaseClass}');
//       print('   Feature  : ${naming.featureCap}  ($featurePath)');
//       print('   Package  : $packageName');
//       print('');
//
//       // 1. Generate UseCase file
//       final usecaseGen = UsecaseGenerator(featurePath, naming);
//       await usecaseGen.generate();
//
//       // 2. Update BaseRepository
//       final repoGen = RepositoryGenerator(featurePath, naming);
//       await repoGen.updateBaseRepository();
//
//       // 3. Update Repository impl
//       await repoGen.updateRepositoryImpl();
//
//       // 4. Update DataSource
//       final dsGen = DataSourceGenerator(featurePath, naming);
//       await dsGen.updateDataSource();
//
//       // 5. Update Cubit
//       final cubitGen = CubitGenerator(featurePath, naming);
//       await cubitGen.updateCubit();
//
//       // 6 & 7. Regenerate DI and barrel files (optional)
//       await _runScriptIfExists('generate_di.sh', [featurePath, packageName]);
//       await _runScriptIfExists('generate_paths.sh', [featurePath, packageName]);
//
//       print('');
//       print('🎉 Done! UseCase \'${naming.usecaseClass}\' added to \'${naming.featureCap}\' feature.');
//       print('');
//       print('📝 Next steps:');
//       print('   • Update ${naming.requestClass} fields to match your API');
//       print('   • Update the endpoint in DataSource');
//       print('   • Call ${naming.actionCamel}() from UI');
//     } catch (e) {
//       print('❌ Error: $e');
//       exit(1);
//     }
//   }
//
//   void _printHelp(ArgParser parser) {
//     print('''
// Usage: dart run add_usecase <feature_path> <usecase_action> [options]
//
// Adds a new UseCase to an existing feature (clean architecture)
//
// Options:
// ${parser.usage}
//
// Examples:
//   dart run add_usecase lib/features/Profile update_profile
//   dart run add_usecase lib/features/Auth login --package=myapp
// ''');
//   }
//
//   Future<void> _runScriptIfExists(String scriptName, List<String> args) async {
//     final scriptDir = Directory.current.path;
//     final scriptPath = path.join(scriptDir, scriptName);
//
//     if (await File(scriptPath).exists()) {
//       print('Running $scriptName...');
//       final result = await Process.run('bash', [scriptPath, ...args]);
//       if (result.exitCode == 0) {
//         print('✅ $scriptName completed');
//       } else {
//         print('⚠️ $scriptName failed: ${result.stderr}');
//       }
//     } else {
//       print('⚠️ $scriptName not found - skipping');
//     }
//   }
// }