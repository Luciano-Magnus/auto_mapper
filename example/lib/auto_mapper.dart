// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:auto_mapper/auto_mapper.dart';

import 'package:example/entity/box_entity.dart';
import 'package:example/dtos/box_dto.dart';
import 'package:example/entity/container_entity.dart';
import 'package:example/dtos/container_dto.dart';
import 'package:example/entity/item_entity.dart';
import 'package:example/dtos/item_dto.dart';
import 'package:example/entity/warehouse_entity.dart';
import 'package:example/dtos/warehouse_dto.dart';

class GeneratedMappings {
  static void register() {
    AutoMapper.add<BoxDto, BoxEntity>(
      (BoxDto source) => BoxEntity(
        container: AutoMapper.convert<ContainerDto, ContainerEntity>(
          source.container,
        ),
      ),
    );

    AutoMapper.add<ContainerDto, ContainerEntity>(
      (ContainerDto source) => ContainerEntity(
        items:
            source.items
                .map((item) => AutoMapper.convert<ItemDto, ItemEntity>(item))
                .toList(),
      ),
    );

    AutoMapper.add<ItemDto, ItemEntity>(
      (ItemDto source) => ItemEntity(
        name: source.name,
        quantity: source.quantity,
        isAvailable: source.isAvailable,
        status: source.status,
        metadata: source.metadata,
        additionalInfo: source.additionalInfo,
      ),
    );

    AutoMapper.add<WarehouseDto, WarehouseEntity>(
      (WarehouseDto source) => WarehouseEntity(
        boxes:
            source.boxes
                .map((item) => AutoMapper.convert<BoxDto, BoxEntity>(item))
                .toList(),
      ),
    );

    AutoMapper.add<BoxEntity, BoxDto>(
      (BoxEntity source) => BoxDto(
        container: AutoMapper.convert<ContainerEntity, ContainerDto>(
          source.container,
        ),
      ),
    );

    AutoMapper.add<ContainerEntity, ContainerDto>(
      (ContainerEntity source) => ContainerDto(
        items:
            source.items
                .map((item) => AutoMapper.convert<ItemEntity, ItemDto>(item))
                .toList(),
      ),
    );

    AutoMapper.add<ItemEntity, ItemDto>(
      (ItemEntity source) => ItemDto(
        name: source.name,
        quantity: source.quantity,
        isAvailable: source.isAvailable,
        status: source.status,
        metadata: source.metadata,
        additionalInfo: source.additionalInfo,
      ),
    );

    AutoMapper.add<WarehouseEntity, WarehouseDto>(
      (WarehouseEntity source) => WarehouseDto(
        boxes:
            source.boxes
                .map((item) => AutoMapper.convert<BoxEntity, BoxDto>(item))
                .toList(),
      ),
    );
  }
}
