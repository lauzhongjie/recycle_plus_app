import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/repositories/r_category_repository.dart';

class CreateNewRCategoryItemUseCase {
  final RCategoryRepository repository;

  CreateNewRCategoryItemUseCase({required this.repository});

  Future<void> call(String categoryId, RCategoryItemEntity item) {
    return repository.createNewRCategoryItem(categoryId, item);
  }
}
