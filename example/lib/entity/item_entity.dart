import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/dtos/item_dto.dart';
import 'package:example/enums/status.dart';

@AutoMap(target: ItemDto)
class ItemEntity {
  String name;
  int quantity;
  bool isAvailable;
  Status status;
  dynamic metadata;
  Map<String, dynamic> additionalInfo;

  ItemEntity({
    required this.name,
    required this.quantity,
    required this.isAvailable,
    required this.status,
    required this.metadata,
    required this.additionalInfo,
  });

  @override
  String toString() {
    return 'ItemEntity{name: $name, quantity: $quantity, isAvailable: $isAvailable, status: $status, metadata: $metadata, additionalInfo: $additionalInfo}';
  }
}