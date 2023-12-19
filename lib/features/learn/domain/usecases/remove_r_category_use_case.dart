import 'package:recycle_plus_app/features/learn/domain/repositories/r_category_repository.dart';

class RemoveRCategoryUseCase {
  final RCategoryRepository repository;

  RemoveRCategoryUseCase({required this.repository});

  Future<void> call(String id) {
    return repository.removeRCategory(id);
  }
}
