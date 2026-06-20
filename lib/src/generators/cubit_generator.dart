import 'dart:io';

import 'package:path/path.dart' as path;

import '../services/file_service.dart';
import '../services/naming_service.dart';

class CubitGenerator {
  final String featurePath;
  final NamingUtils naming;

  CubitGenerator(this.featurePath, this.naming);

  Future<void> updateCubit() async {
    final cubitFile = await FileUtils.findFile(
      path.join(featurePath, 'presentation', 'controllers'),
      '${naming.featureLower}_cubit.dart',
    );

    if (cubitFile == null) {
      print('⚠️  Cubit file not found – skipping');
      return;
    }

    if (await FileUtils.containsPattern(cubitFile, naming.fieldName)) {
      print('⚠️  UseCase already injected in Cubit – skipping');
      return;
    }

    var content = await File(cubitFile).readAsString();
    var modified = false;

    // 1. Add field declaration
    final fieldDecl = '  final ${naming.usecaseClass} ${naming.fieldName};';
    final classPattern =
        RegExp(r'class\s+\w+Cubit\s+extends\s+(?:Base)?Cubit<\w+State>\s*\{');

    if (!content.contains(fieldDecl)) {
      content = content.replaceFirstMapped(
        classPattern,
        (match) => '${match.group(0)}\n$fieldDecl',
      );
      modified = true;
    }

    // 2. Update constructor
    final constructorPattern = RegExp(r'(\w+Cubit\(\))|(\w+Cubit\(([^)]+)\))');

    content = content.replaceFirstMapped(
      constructorPattern,
      (match) {
        final fullMatch = match.group(0)!;

        if (fullMatch.contains('()')) {
          // Case 1: Empty constructor - FeatureCubit()
          return fullMatch.replaceFirst('()', '(this.${naming.fieldName})');
        } else {
          // Case 2: Constructor with params - FeatureCubit(this.param1, this.param2)
          if (!fullMatch.contains(naming.fieldName)) {
            // Add new param at the end
            final lastParen = fullMatch.lastIndexOf(')');
            final before = fullMatch.substring(0, lastParen);
            if (before.trimRight().endsWith(',')) {
              return '$before this.${naming.fieldName},)';
            } else {
              return '$before, this.${naming.fieldName})';
            }
          }
          return fullMatch;
        }
      },
    );

    // 3. Add action method if not exists
    final actionMethodPattern = '${naming.actionCamel}${naming.featureCap}()';
    if (!content.contains(actionMethodPattern)) {
      final actionMethod = '''
  Future<void> ${naming.actionCamel}${naming.featureCap}() async {
    emit(state.copyWith(pageState: PageState.loading));
    try {
      final result = await ${naming.fieldName}(
        const  ${naming.requestClass}(id: 1),
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
''';

      final lastBraceIndex = content.lastIndexOf('}');
      if (lastBraceIndex != -1) {
        content = content.substring(0, lastBraceIndex) +
            actionMethod +
            content.substring(lastBraceIndex);
        modified = true;
      }
    }

    if (modified) {
      await File(cubitFile).writeAsString(content);
      print('✅ Cubit updated : $cubitFile');
    } else {
      print('⚠️ Cubit already contains the necessary changes');
    }
  }
}
