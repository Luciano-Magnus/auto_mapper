import 'package:auto_mapper/auto_mapper_annotation.dart';
import 'package:example/dtos/box_dto.dart';
import 'package:example/entity/base_entity.dart';
import 'package:example/entity/container_entity.dart';

@AutoMap(target: BoxDto)
class BoxEntity extends BaseEntity {
  ContainerEntity container;
  List<String> teste;

  BoxEntity({
    required super.id,
    required super.dataHoraCriado,
    required super.dataHoraDeletado,
    required this.container,
    required this.teste,
  });

  @override
  String toString() {
    return 'BoxEntity{container: $container}';
  }
}