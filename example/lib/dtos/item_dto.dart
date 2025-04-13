import 'package:auto_mapper/auto_mapper_annotation.dart';
import 'package:example/dtos/class_teste.dart';
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

  @AutoMapFieldValue(
      defaultValue: const ClassTest(
      id: 1,
      name: 'test 1234',
      items: [
          ClassTest(id: 2, name: 'name 1'),
          ClassTest(id: 3, name: 'name 2')
        ],
      test: ClassTest(id: 4, name: 'name 3'),
      ),
  )
  ClassTest test;

  ItemDto({
    required this.name,
    required this.quantity,
    required this.isAvailable,
    required this.status,
    required this.metadata,
    required this.additionalInfo,
    required this.test,
  });

  @override
  String toString() {
    return '''
    ItemDto {
      name: $name,
      quantity: $quantity,
      isAvailable: $isAvailable,
      status: $status,
      metadata: $metadata,
      additionalInfo: $additionalInfo,
      test: $test
    }
    ''';
  }
}