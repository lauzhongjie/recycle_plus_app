import 'dart:io';

import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/repositories/r_category_repository.dart';

class UpdateRCategoryUseCase {
  final RCategoryRepository repository;

  UpdateRCategoryUseCase({required this.repository});

  Future<void> call(RCategoryEntity category, File? imgFile) {
    return repository.updateRCategory(category, imgFile);
  }
}
