// import '../core/registry/generator_registry.dart';
// import '../services/file_service.dart';
//
// class BaseRepositoryGenerator implements Generator {
//   final String baseRepoPath;
//   final String methodSignature;
//
//   BaseRepositoryGenerator({
//     required this.baseRepoPath,
//     required this.methodSignature,
//   });
//
//   @override
//    generate() {
//     final content = FileService.readFile(baseRepoPath);
//
//     if (content.contains(methodSignature)) return;
//
//     final updated = _inject(content, methodSignature);
//
//     FileService.writeFile(baseRepoPath, updated);
//   }
//
//   String _inject(String content, String code) {
//     final index = content.lastIndexOf('}');
//     return content.substring(0, index) + '\n$code\n' + content.substring(index);
//   }
// }
