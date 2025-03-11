import 'package:auto_mapper/auto_mapper.dart';
import 'package:example/entity/item_entity.dart';
import 'package:example/enums/status.dart';

@AutoMap(target: ItemEntity)
class ItemDto {
  String name;
  int quantity;
  bool isAvailable;
  Status status;
  dynamic metadata;
  Map<String, dynamic> additionalInfo;

  ItemDto({
    required this.name,
    required this.quantity,
    required this.isAvailable,
    required this.status,
    this.metadata,
    required this.additionalInfo,
  });

  @override
  String toString() {
    return 'ItemDto{name: $name, quantity: $quantity, isAvailable: $isAvailable, status: $status, metadata: $metadata, additionalInfo: $additionalInfo}';
  }
}