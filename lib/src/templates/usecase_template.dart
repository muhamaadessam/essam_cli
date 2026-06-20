String buildUseCaseTemplate({
  required String featureLower,
  required String featureCap,
  required String usecaseClass,
  required String requestClass,
  required String responseClass,
  required String actionCamel,
}) {
  return '''
// GENERATED FILE - DO NOT EDIT

import 'package:equatable/equatable.dart';
import '../../$featureLower.dart';

class $usecaseClass extends BaseUseCase<$responseClass, $requestClass> {
  final Base${featureCap}Repository repository;

  $usecaseClass(this.repository);

  @override
  Future<Result<$responseClass>> call($requestClass params) async {
    return await repository.$actionCamel(params);
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

  factory $responseClass.fromJson(Map<String, dynamic> json) {
    return $responseClass(
      id: json['id'],
    );
  }

  @override
  List<Object?> get props => [id];
}
''';
}
