import 'package:recycle_plus_app/features/learn/domain/repositories/r_category_repository.dart';

class RemoveRCategoryItemUseCase {
  final RCategoryRepository repository;

  RemoveRCategoryItemUseCase({required this.repository});

  Future<void> call(String catId, String itemId) {
    return repository.removeRCategoryItem(catId, itemId);
  }
}
