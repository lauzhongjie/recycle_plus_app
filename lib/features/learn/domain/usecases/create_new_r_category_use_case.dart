import 'dart:io';

import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/repositories/r_category_repository.dart';

class CreateNewRCategoryUseCase {
  final RCategoryRepository repository;

  CreateNewRCategoryUseCase({required this.repository});

  Future<void> call(RCategoryEntity category, File file) {
    return repository.createNewRCategory(category, file);
  }
}
