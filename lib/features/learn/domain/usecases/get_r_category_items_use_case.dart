import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/repositories/r_category_repository.dart';

class GetRCategoryItemsUseCase {
  final RCategoryRepository repository;

  GetRCategoryItemsUseCase({required this.repository});

  Stream<List<RCategoryItemEntity>> call(String categoryId) {
    return repository.getRCategoryItems(categoryId);
  }
}
