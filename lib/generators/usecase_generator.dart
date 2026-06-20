import 'dart:io';

import 'package:path/path.dart' as path;

import '../services/naming_service.dart';


class UsecaseGenerator {
  final String featurePath;
  final NamingUtils naming;

  UsecaseGenerator(this.featurePath, this.naming);

  Future<void> generate() async {
    final usecaseDir = path.join(featurePath, 'domain', 'use_cases');
    await Directory(usecaseDir).create(recursive: true);

    final usecaseFile = path.join(usecaseDir, '${naming.actionLower}_use_case.dart');

    if (await File(usecaseFile).exists()) {
      print('⚠️  UseCase already exists, skipping creation: $usecaseFile');
      return;
    }

    final content = '''
// GENERATED FILE - DO NOT EDIT

import 'package:equatable/equatable.dart';
import '../../${naming.featureLower}.dart';

class ${naming.usecaseClass} extends BaseUseCase<${naming.responseClass}, ${naming.requestClass}> {
  final Base${naming.featureCap}Repository repository;

  ${naming.usecaseClass}(this.repository);

  @override
  Future<Result<${naming.responseClass}>> call(${naming.requestClass} params) async {
    return await repository.${naming.actionCamel}(params);
  }
}

class ${naming.requestClass} extends Equatable {
  final int id;
 

  const ${naming.requestClass}({
    required this.id,
 
  });

  Map<String, dynamic> toJson() => {
        'id': id,
      };

  @override
  List<Object?> get props => [id];
}

class ${naming.responseClass} extends Equatable {
  final int id;

  const ${naming.responseClass}({
    required this.id,
  });

  Map<String, dynamic> toJson() => {
    'id': id
  };

  factory ${naming.responseClass}.fromJson(Map<String, dynamic> json) {
    return ${naming.responseClass}(
      id: json['id'],
    );
  }
  
  @override
  List<Object?> get props => [id];
}
''';

    await File(usecaseFile).writeAsString(content);
    print('✅ UseCase created : $usecaseFile');
  }
}