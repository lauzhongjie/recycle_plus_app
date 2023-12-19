import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';

class RCategoryEntity extends Equatable {
  final String? id;
  final String? name;
  final String? imageUrl;
  final List<RCategoryItemEntity>? itemList;

  const RCategoryEntity({
    this.id,
    this.name,
    this.imageUrl,
    this.itemList,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        itemList,
      ];
}
