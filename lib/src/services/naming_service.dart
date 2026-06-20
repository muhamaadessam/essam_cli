class NamingUtils {
  final String rawFeature;
  final String usecaseAction;

  late final String featureLower;
  late final String featureCap;
  late final String actionLower;
  late final String actionPascal;
  late final String actionCamel;
  late final String usecaseClass;
  late final String requestClass;
  late final String responseClass;
  late final String fieldName;

  NamingUtils(this.rawFeature, this.usecaseAction) {
    // Feature names
    featureLower = _toSnakeCase(rawFeature);
    featureCap = '${rawFeature[0].toUpperCase()}${rawFeature.substring(1)}';

    // UseCase action names
    actionLower = usecaseAction.toLowerCase().replaceAll(' ', '_');
    actionPascal = _toPascalCase(actionLower);
    actionCamel = '${actionPascal[0].toLowerCase()}${actionPascal.substring(1)}';

    // Full class names
    usecaseClass = '${actionPascal}UseCase';
    requestClass = '${actionPascal}Request';
    responseClass = '${actionPascal}Response';
    fieldName = '${actionCamel}UseCase';
  }

  String _toSnakeCase(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (i > 0 && char.toUpperCase() == char && RegExp(r'[A-Z]').hasMatch(char)) {
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
}