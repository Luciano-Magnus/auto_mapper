import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/dtos/warehouse_dto.dart';
import 'package:example/entity/box_entity.dart';

@AutoMap(target: WarehouseDto)
class WarehouseEntity {
  List<BoxEntity> boxes;

  WarehouseEntity({required this.boxes});

  @override
  String toString() {
    return 'WarehouseDto{boxes: $boxes}';
  }
}
