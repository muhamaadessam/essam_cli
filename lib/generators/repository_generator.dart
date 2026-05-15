
import 'package:path/path.dart' as path;

import '../services/file_service.dart';
import '../services/naming_service.dart';


class RepositoryGenerator {
  final String featurePath;
  final NamingUtils naming;

  RepositoryGenerator(this.featurePath, this.naming);

  Future<void> updateBaseRepository() async {
    final baseRepoFile = await FileUtils.findFile(
      path.join(featurePath, 'domain', 'repository'),
      'base_',
    );

    if (baseRepoFile == null) {
      print('⚠️  BaseRepository file not found – skipping');
      return;
    }

    final methodSig =
        '  Future<Either<Failure, ${naming.responseClass}>> ${naming.actionCamel}(${naming.requestClass} params);';

    if (await FileUtils.containsPattern(baseRepoFile, naming.actionCamel)) {
      print('⚠️  Method already in BaseRepository – skipping');
      return;
    }

    await FileUtils.insertBeforeLastBrace(baseRepoFile, '$methodSig\n');
    print('✅ Method added to BaseRepository : $baseRepoFile');
  }

  Future<void> updateRepositoryImpl() async {
    final repoFile = await FileUtils.findFile(
      path.join(featurePath, 'data', 'repository'),
      '${naming.featureLower}_repository.dart',
    );

    if (repoFile == null) {
      print('⚠️  Repository file not found – skipping');
      return;
    }

    if (await FileUtils.containsPattern(repoFile, naming.actionCamel)) {
      print('⚠️  Method already in Repository – skipping');
      return;
    }

    final methodImpl = '''
  @override
  Future<Either<Failure, ${naming.responseClass}>> ${naming.actionCamel}(${naming.requestClass} params) async {
    return await base${naming.featureCap}RemoteDataSource.${naming.actionCamel}(params);
  }
''';

    await FileUtils.insertBeforeLastBrace(repoFile, methodImpl);
    print('✅ Method added to Repository : $repoFile');
  }
}