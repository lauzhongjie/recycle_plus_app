import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/repositories/r_category_repository.dart';

class GetRCategoriesUseCase {
  final RCategoryRepository repository;

  GetRCategoriesUseCase({required this.repository});

  Stream<List<RCategoryEntity>> call() {
    return repository.getRCategories();
  }
}
