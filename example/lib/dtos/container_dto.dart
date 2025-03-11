import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/dtos/item_dto.dart';
import 'package:example/entity/container_entity.dart';

@AutoMap(target: ContainerEntity)
class ContainerDto {
  List<ItemDto> items;

  ContainerDto({required this.items});

  @override
  String toString() {
    return 'ContainerDto{items: $items}';
  }
}