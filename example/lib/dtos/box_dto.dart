import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/dtos/container_dto.dart';
import 'package:example/entity/box_entity.dart';

@AutoMap(target: BoxEntity)
class BoxDto {
  ContainerDto container;

  BoxDto({required this.container});

  @override
  String toString() {
    return 'BoxDto{container: $container}';
  }
}