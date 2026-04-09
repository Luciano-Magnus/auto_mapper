import 'package:auto_mapper/auto_mapper_annotation.dart';
import 'package:example/entity/base_entity.dart';

@AutoMap(target: BaseEntity)
class BaseDto {
  String id;
  DateTime dataHoraCriado;
  DateTime? dataHoraDeletado;

  BaseDto({required this.id, required this.dataHoraCriado, required this.dataHoraDeletado});
}
