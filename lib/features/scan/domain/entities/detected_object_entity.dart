import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';

class DetectedObjectEntity {
  final RCategoryItemEntity item;
  final RCategoryEntity category;
  int count;

  DetectedObjectEntity({
    required this.item,
    required this.category,
    required this.count,
  });

  List<Object?> get props => [
        item,
        category,
        count
      ];
}
