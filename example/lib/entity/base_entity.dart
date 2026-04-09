import 'package:auto_mapper/auto_mapper_annotation.dart';
import 'package:example/dtos/base_dto.dart';

@AutoMap(target: BaseDto)
class BaseEntity {
  String id;
  DateTime dataHoraCriado;
  DateTime? dataHoraDeletado;

  BaseEntity({required this.id, required this.dataHoraCriado, required this.dataHoraDeletado});
}
