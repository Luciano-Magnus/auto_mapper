import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/auto_mapper.dart';
import 'package:example/dtos/box_dto.dart';
import 'package:example/dtos/container_dto.dart';
import 'package:example/dtos/item_dto.dart';
import 'package:example/dtos/warehouse_dto.dart';
import 'package:example/entity/warehouse_entity.dart';
import 'package:example/enums/status.dart';

void main() async {
  GeneratedMappings.register();

  ItemDto item1 = ItemDto(
    name: "Laptop",
    quantity: 10,
    isAvailable: true,
    status: Status.active,
    metadata: {
      "brand": "Dell",
      "specs": ["16GB RAM", "512GB SSD"],
    },
    additionalInfo: {"warranty": "2 years", "location": "Aisle 3"},
  );

  ContainerDto container = ContainerDto(items: [item1]);
  BoxDto box = BoxDto(container: container);
  WarehouseDto warehouse = WarehouseDto(boxes: [box]);

  var warehouseEntity = AutoMapper.convert<WarehouseDto, WarehouseEntity>(warehouse);

  print('Warehouse Entity: $warehouseEntity');

  print('\n-----------------------------------\n');

  var warehouseDto = AutoMapper.convert<WarehouseEntity, WarehouseDto>(warehouseEntity);

  print('Warehouse DTO: $warehouseDto');
}
