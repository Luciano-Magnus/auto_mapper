import 'package:auto_mapper/auto_mapper_annotation.dart';
import 'package:example/dtos/container_dto.dart';
import 'package:example/entity/box_entity.dart';

@AutoMap(target: BoxEntity)
class BoxDto {
  ContainerDto container;
  List<String> teste;

  BoxDto({
    required this.container,
    required this.teste,
  });

  @override
  String toString() {
    return 'BoxDto{container: $container}, teste: $teste';
  }
}