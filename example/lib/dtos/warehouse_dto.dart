import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/dtos/box_dto.dart';
import 'package:example/entity/warehouse_entity.dart';

@AutoMap(target: WarehouseEntity)
class WarehouseDto {
  List<BoxDto> boxes;

  WarehouseDto({required this.boxes});

  @override
  String toString() {
    return 'WarehouseDto{boxes: $boxes}';
  }
}