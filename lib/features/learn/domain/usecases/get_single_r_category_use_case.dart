import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/repositories/r_category_repository.dart';

class GetSingleRCategoryUseCase {
  final RCategoryRepository repository;

  GetSingleRCategoryUseCase({required this.repository});

  Stream<List<RCategoryEntity>> call(String id) {
    return repository.getSingleRCategory(id);
  }
}
