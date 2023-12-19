import 'package:equatable/equatable.dart';

class RCategoryItemEntity extends Equatable {
  final String? id;
  final String? name;
  final bool? recyclability;
  final List<String>? recyclingStepList;

  const RCategoryItemEntity({
    this.id,
    this.name,
    this.recyclability,
    this.recyclingStepList,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        recyclability,
        recyclingStepList,
      ];
}
