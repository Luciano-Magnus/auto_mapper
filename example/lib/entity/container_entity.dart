import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/dtos/container_dto.dart';
import 'package:example/entity/item_entity.dart';

@AutoMap(target: ContainerDto)
class ContainerEntity {
  List<ItemEntity> items;

  ContainerEntity({required this.items});

  @override
  String toString() {
    return 'ContainerEntity{items: $items}';
  }
}