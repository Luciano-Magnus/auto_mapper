import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/dtos/box_dto.dart';
import 'package:example/entity/container_entity.dart';

@AutoMap(target: BoxDto)
class BoxEntity {
  ContainerEntity container;

  BoxEntity({required this.container});

  @override
  String toString() {
    return 'BoxEntity{container: $container}';
  }
}