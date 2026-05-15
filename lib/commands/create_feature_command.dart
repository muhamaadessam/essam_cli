import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import 'generate_di_command.dart';
import 'generate_paths_command.dart';

class CreateFeatureCommand {
  void run(List<String> arguments, {String? workingDirectory}) async {
    final parser = ArgParser()
      ..addOption('package',
          abbr: 'p', help: 'Package name', defaultsTo: 'twafok')
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

      if (args.isEmpty) {
        print('❌ Feature name is required');
        print('👉 Usage: twafok create_feature <feature_name>');
        exit(1);
      }

      final featureName = args[0];
      final basePath = 'lib/features';
      final featurePath = path.join(workDir, basePath, featureName);

      // Check if feature already exists
      if (await Directory(featurePath).exists()) {
        print('⚠️ Feature already exists: $featurePath');
        exit(1);
      }

      print('');
      print('🚀 Creating feature: $featureName');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Create feature structure
      await _createFeatureStructure(featurePath);

      // Generate all files
      await _generateEntityModel(featurePath, featureName, packageName);
      await _createUseCase(featurePath, featureName);
      await _createBaseRepository(featurePath, featureName);
      await _createRepository(featurePath, featureName);
      await _createRemoteDataSource(featurePath, featureName);
      await _generateCubit(featurePath, featureName, packageName);
      await _createScreen(featurePath, featureName, packageName);

      // Generate DI and barrel files
      print('');
      print('🔄 Generating DI and barrel files...');
      final diCommand = GenerateDiCommand();
      diCommand.run([featurePath], workingDirectory: workDir);

      final pathsCommand = GeneratePathsCommand();
      pathsCommand.run([featurePath], workingDirectory: workDir);

      print('');

      // Format the project
      await _formatProject(workDir);
      print('');

      // Run dart fix
      await _runDartFix(workDir);

      print('');
      print('🎉 Feature \'$featureName\' created successfully!');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('');
      print('📁 Feature location: $featurePath');
      print('');
      print('📝 Next steps:');
      print('   1. Add your business logic to the cubit');
      print('   2. Update the API endpoints in remote_data_source');
      print(
          '   3. Add more use cases using: twafok add_usecase $featurePath <action>');
    } catch (e) {
      print('❌ Error: $e');
      exit(1);
    }
  }

  Future<void> _createFeatureStructure(String featurePath) async {
    print('📁 Creating feature structure...');

    final directories = [
      'data/data_sources',
      'data/models',
      'data/repositories',
      'domain/entities',
      'domain/repositories',
      'domain/use_cases',
      'presentation/controllers',
      'presentation/screens',
      'presentation/widgets',
    ];

    for (var dir in directories) {
      final fullPath = path.join(featurePath, dir);
      await Directory(fullPath).create(recursive: true);
      print('  ✅ Created: ${path.join(featurePath, dir)}');
    }
  }

  Future<void> _generateEntityModel(
      String featurePath, String featureName, String packageName) async {
    print('📝 Generating entity and model...');

    final featureNameCap = _toPascalCase(featureName);
    final featureNameLower = _toSnakeCase(featureName);
    final actionLower = 'get$featureNameCap';
    final actionCap = 'Get$featureNameCap';
    final responseClass = '${actionCap}Response';
    // Create Entity
    final entityFile = path.join(
        featurePath, 'domain', 'entities', '${featureNameLower}_entity.dart');
    final entityContent = '''
// GENERATED FILE - DO NOT EDIT

import 'package:equatable/equatable.dart';

class ${featureNameLower}Entity extends Equatable {
  final int id;
  final String name;

  const ${featureNameLower}Entity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
''';
    await File(entityFile).writeAsString(entityContent);
    print('  ✅ Entity created: ${path.basename(entityFile)}');

    // Create Model
    final modelFile = path.join(
        featurePath, 'data', 'models', '${featureNameLower}_model.dart');
    final modelContent = '''
// GENERATED FILE - DO NOT EDIT

import '../../$featureNameLower.dart';

class ${featureNameCap}Model extends ${featureNameLower}Entity {
  const ${featureNameCap}Model({
    required super.id,
    required super.name,
  });

  factory ${featureNameCap}Model.fromJson(Map<String, dynamic> json) => ${featureNameCap}Model(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
''';
    await File(modelFile).writeAsString(modelContent);
    print('  ✅ Model created: ${path.basename(modelFile)}');
  }

  Future<void> _createBaseRepository(
      String featurePath, String featureName) async {
    final featureNameCap = _toPascalCase(featureName);
    final featureNameLower = _toSnakeCase(featureName);
    final actionLower = 'get$featureNameCap';
    final actionCap = 'Get$featureNameCap';
    final responseClass = '${actionCap}Response';

    final repoFile = path.join(featurePath, 'domain', 'repositories',
        'base_${featureNameLower}_repository.dart');
    final content = '''
// GENERATED FILE - DO NOT EDIT

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../$featureNameLower.dart';

abstract class Base${featureNameCap}Repository {
  Future<Either<Failure, $responseClass>> $actionLower(params);
}
''';
    await File(repoFile).writeAsString(content);
    print('  ✅ Base repository created: ${path.basename(repoFile)}');
  }

  Future<void> _createRepository(String featurePath, String featureName) async {
    final featureNameCap = _toPascalCase(featureName);
    final featureNameLower = _toSnakeCase(featureName);

    final actionLower = 'get$featureNameCap';
    final actionCap = 'Get$featureNameCap';
    final responseClass = '${actionCap}Response';

    final repoFile = path.join(featurePath, 'data', 'repositories',
        '${featureNameLower}_repository.dart');
    final content = '''
// GENERATED FILE - DO NOT EDIT

import 'package:dartz/dartz.dart';
import '../../$featureNameLower.dart';

class ${featureNameCap}Repository extends Base${featureNameCap}Repository {
  final Base${featureNameCap}RemoteDataSource base${featureNameCap}RemoteDataSource;

  ${featureNameCap}Repository(this.base${featureNameCap}RemoteDataSource);

  @override
  Future<Either<Failure, $responseClass>> $actionLower(params) async {
    return await base${featureNameCap}RemoteDataSource.$actionLower(params);
  }
}
''';
    await File(repoFile).writeAsString(content);
    print('  ✅ Repository created: ${path.basename(repoFile)}');
  }

  Future<void> _createRemoteDataSource(
      String featurePath, String featureName) async {
    final featureNameCap = _toPascalCase(featureName);
    final featureNameLower = _toSnakeCase(featureName);
    final actionLower = 'get$featureNameCap';
    final actionCap = 'Get$featureNameCap';
    final responseClass = '${actionCap}Response';
    final requestClass = '${actionCap}Request';
    final dsFile = path.join(featurePath, 'data', 'data_sources',
        '${featureNameLower}_remote_data_source.dart');
    final content = '''
// GENERATED FILE - DO NOT EDIT

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../$featureNameLower.dart';

abstract class Base${featureNameCap}RemoteDataSource {
  Future<Either<Failure, $responseClass>> $actionLower($requestClass params);
}

class ${featureNameCap}RemoteDataSource implements Base${featureNameCap}RemoteDataSource {
  @override
  Future<Either<Failure, $responseClass>> $actionLower($requestClass params) async {
    try {
      final response = await DioHelper.getData(
        endPoint: 'TODO_ADD_ENDPOINT',
        query: params.toJson(),
      );
      return response.fold((failure) {
        return Left(failure);
      }, (data) {
        return Right($responseClass.fromJson(data['data']));
      });
    } on DioException catch (e) {
      return Left(ServerFailure(DioHelper.handleError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
''';
    await File(dsFile).writeAsString(content);
    print('  ✅ Remote data source created: ${path.basename(dsFile)}');
  }

  Future<void> _createUseCase(String featurePath, String featureName) async {
    final featureNameCap = _toPascalCase(featureName);
    final featureNameLower = _toSnakeCase(featureName);
    final useCaseClass = 'Get${featureNameCap}UseCase';
    final actionLower = 'get$featureNameCap';
    final actionCap = 'Get$featureNameCap';
    final responseClass = '${actionCap}Response';
    final requestClass = '${actionCap}Request';

    final useCaseFile = path.join(featurePath, 'domain', 'use_cases',
        'get_${featureNameLower}_use_case.dart');
    final content = '''
// GENERATED FILE - DO NOT EDIT

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../$featureNameLower.dart';

class $useCaseClass extends BaseUseCase<$responseClass,$requestClass> {
  final Base${featureNameCap}Repository repository;

  $useCaseClass(this.repository);

  @override
  Future<Either<Failure, $responseClass>> call($requestClass params) async {
    return await repository.$actionLower(params);
  }
}

class $requestClass extends Equatable {
  final int id;
 

  const $requestClass({
    required this.id,
 
  });

  Map<String, dynamic> toJson() => {
        'id': id,
      };

  @override
  List<Object?> get props => [id];
}

class $responseClass extends Equatable {
  final int id;

  const $responseClass({
    required this.id,
  });

  Map<String, dynamic> toJson() => {
    'id': id
  };

  factory $responseClass.fromJson(Map<String, dynamic> json) {
    return $responseClass(
      id: json['id'],
    );
  }
  
  @override
  List<Object?> get props => [id];
}
''';
    await File(useCaseFile).writeAsString(content);
    print('  ✅ UseCase created: ${path.basename(useCaseFile)}');
  }

  Future<void> _generateCubit(
      String featurePath, String featureName, String packageName) async {
    final featureNameCap = _toPascalCase(featureName);
    final featureNameLower = _toSnakeCase(featureName);
    final actionLower = 'get$featureNameCap';
    final actionCap = 'Get$featureNameCap';
    final requestClass = '${actionCap}Request';
    // Detect UseCases
    final useCasesDir =
        Directory(path.join(featurePath, 'domain', 'use_cases'));
    final useCaseClasses = <String>[];

    if (await useCasesDir.exists()) {
      await for (var file in useCasesDir.list()) {
        if (file is File && file.path.endsWith('_use_case.dart')) {
          final filename = path.basenameWithoutExtension(file.path);
          final pascalCase = _toPascalCase(filename);
          useCaseClasses.add(pascalCase);
        }
      }
    }

    // Build constructor params
    final constructorParams = StringBuffer();
    final useCaseFields = StringBuffer();

    for (var uc in useCaseClasses) {
      final lcName = '${uc[0].toLowerCase()}${uc.substring(1)}';
      constructorParams.write('this.$lcName, ');
      useCaseFields.writeln('  final $uc $lcName;');
    }

    final constructorStr =
        constructorParams.toString().replaceAll(RegExp(r', $'), '');

    // State file
    final stateFile = path.join(featurePath, 'presentation', 'controllers',
        '${featureNameLower}_state.dart');
    final stateContent = '''
// GENERATED FILE - DO NOT EDIT

part of '${featureNameLower}_cubit.dart';


class ${featureNameCap}State extends BaseState {
  

 const ${featureNameCap}State({
    super.pageState = PageState.init,
    super.failure,
    super.successMessage,
    super.successIcon,
    });
    
  @override
  ${featureNameCap}State copyWith({
    PageState? pageState,
    Failure? failure,
    String? successMessage,
    String? successIcon,
  }) {
    return ${featureNameCap}State(
      pageState: pageState ?? this.pageState,
      failure: failure ?? this.failure,
      successMessage: successMessage ?? this.successMessage,
      successIcon: successIcon ?? this.successIcon,
    );
  }
    @override
  List<Object> get props => [
        pageState,
      ];
}
''';
    await File(stateFile).writeAsString(stateContent);

    // Cubit file
    final cubitFile = path.join(featurePath, 'presentation', 'controllers',
        '${featureNameLower}_cubit.dart');
    final cubitContent = '''
// GENERATED FILE - DO NOT EDIT

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../$featureNameLower.dart';
part '${featureNameLower}_state.dart';

class ${featureNameCap}Cubit extends BaseCubit<${featureNameCap}State> {

  ${featureNameCap}Cubit($constructorStr) : super(const ${featureNameCap}State());
  
  ${useCaseFields.toString()}
  Future<void> $actionLower() async {
    emit(state.copyWith(pageState: PageState.loading));
    try {
      final result = await get${featureNameCap}UseCase(
        const  $requestClass(id: 1),
      );
      result.fold(
        (failure) => emit(state.copyWith(pageState: PageState.errorWithSnackBar,
         failure: failure)),
        (data) => emit(state.copyWith(pageState: PageState.success)),
      );
    } catch (_) {
      emit(state.copyWith(pageState: PageState.errorWithSnackBar));
    }
  }
}
''';
    await File(cubitFile).writeAsString(cubitContent);
    print('  ✅ Cubit and State created');
  }

  Future<void> _createScreen(
      String featurePath, String featureName, String packageName) async {
    final featureNameCap = _toPascalCase(featureName);
    final featureNameLower = _toSnakeCase(featureName);

    final screenFile = path.join(featurePath, 'presentation', 'screens',
        '${featureNameLower}_screen.dart');
    final content = '''
// GENERATED FILE - DO NOT EDIT

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../$featureNameLower.dart';

class ${featureNameCap}Screen extends BaseView<${featureNameCap}Cubit, ${featureNameCap}State> {
  ${featureNameCap}Screen({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(
        title: const Text('$featureNameCap Screen'),
      );
   @override
  Widget body(BuildContext context, ${featureNameCap}State state) =>
      Scaffold(
      body: Center(
        child: const Text('Welcome to $featureNameCap feature!'),
      ),
    );
  
}
''';
    await File(screenFile).writeAsString(content);
    print('  ✅ Screen created: ${path.basename(screenFile)}');
  }

  Future<void> _formatProject(String workDir) async {
    print('🎨 Formatting project code...');
    try {
      final result = await Process.run(
        'dart',
        ['format', '.'],
        workingDirectory: workDir,
        runInShell: true,
      );
      if (result.exitCode == 0) {
        print(' ✅ Project formatted successfully');
      }
    } catch (e) {
      print(' ⚠️ Could not format project: $e');
    }
  }

  Future<void> _runDartFix(String workDir) async {
    print('🔧 Running dart fix --apply...');
    try {
      final result = await Process.run(
        'dart',
        ['fix', '--apply'],
        workingDirectory: workDir,
        runInShell: true,
      );
      if (result.exitCode == 0) {
        print(' ✅ Dart fix completed successfully');
      } else {
        print(' ⚠️ Dart fix had issues: ${result.stderr}');
      }
    } catch (e) {
      print(' ⚠️ Could not run dart fix: $e');
    }
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
║            Twafok CLI - Create Feature Command           ║
╚══════════════════════════════════════════════════════════╝

Usage: 
  twafok create_feature <feature_name>
  twafok create <feature_name> (shortcut)

Creates a complete feature with all layers (domain, data, presentation).

Examples:
  twafok create_feature Profile
  twafok create_feature Authentication
  twafok create Profile (shortcut)

Generated structure:
  lib/features/{feature_name}/
  ├── data/
  │   ├── data_sources/
  │   ├── models/
  │   └── repositories/
  ├── domain/
  │   ├── entities/
  │   ├── repositories/
  │   └── use_cases/
  └── presentation/
      ├── controllers/ (cubit + state)
      ├── screens/
      └── widgets/
''');
  }
}
