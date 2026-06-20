import 'dart:io';

import 'package:path/path.dart' as path;

class FileUtils {
  static Future<String?> findFile(String directory, String pattern) async {
    final dir = Directory(directory);
    if (!await dir.exists()) return null;

    final files = await dir
        .list(recursive: true)
        .where((entity) =>
            entity is File && path.basename(entity.path).contains(pattern))
        .toList();

    if (files.isEmpty) return null;
    return files.first.path;
  }

  static Future<void> insertBeforeLastBrace(
      String filePath, String content) async {
    final file = File(filePath);
    var text = await file.readAsString();

    final lastBrace = text.lastIndexOf('}');
    if (lastBrace == -1) return;

    text = text.substring(0, lastBrace) + content + text.substring(lastBrace);
    await file.writeAsString(text);
  }

  static Future<bool> containsPattern(String filePath, String pattern) async {
    final file = File(filePath);
    if (!await file.exists()) return false;

    final content = await file.readAsString();
    return content.contains(pattern);
  }
}
