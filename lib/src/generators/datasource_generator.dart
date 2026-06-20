import 'dart:io';

import 'package:path/path.dart' as path;

import '../services/file_service.dart';
import '../services/naming_service.dart';

class DataSourceGenerator {
  final String featurePath;
  final NamingUtils naming;

  DataSourceGenerator(this.featurePath, this.naming);

  Future<void> updateDataSource() async {
    final dsFile = await FileUtils.findFile(
      path.join(featurePath, 'data', 'data_sources'),
      '${naming.featureLower}_remote_data_source.dart',
    );

    if (dsFile == null) {
      print('⚠️  RemoteDataSource file not found – skipping');
      return;
    }

    if (await FileUtils.containsPattern(dsFile, naming.actionCamel)) {
      print('⚠️  Method already in DataSource – skipping');
      return;
    }

    final abstractSig =
        '  Future<Result<${naming.responseClass}>> ${naming.actionCamel}(${naming.requestClass} params);';

    final implMethod = '''
  @override
  Future<Result<${naming.responseClass}>> ${naming.actionCamel}(${naming.requestClass} params) async {
    return await DioHelper.getData(
        endPoint: 'TODO_ADD_ENDPOINT',
        query: params.toJson(),
        fromJson: (data) {
          return ${naming.responseClass}.fromJson(data);
        },
    );
  }
''';

    await _insertMethods(dsFile, abstractSig, implMethod);
    print('✅ Methods added to DataSource : $dsFile');
  }

  Future<void> _insertMethods(
      String filePath, String abstractSig, String implMethod) async {
    final file = File(filePath);
    var lines = await file.readAsLines();

    // Find closing braces
    int firstClose = -1;
    int lastClose = -1;

    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trim() == '}') {
        if (firstClose == -1) firstClose = i;
        lastClose = i;
      }
    }

    if (firstClose == lastClose) {
      // Only one class
      lines.insert(lastClose, abstractSig);
    } else {
      lines.insert(firstClose, abstractSig);
      // Recalculate lastClose after insertion
      lastClose = lines.lastIndexWhere((line) => line.trim() == '}');
      lines.insert(lastClose, implMethod);
    }

    await file.writeAsString(lines.join('\n'));
  }
}
