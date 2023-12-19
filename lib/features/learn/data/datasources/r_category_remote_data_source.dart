import 'dart:io';

import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';

abstract class RCategoryRemoteDataSource {
  // Category
  Stream<List<RCategoryEntity>> getSingleRCategory(String id);
  Stream<List<RCategoryEntity>> getRCategories();
  Future<void> createNewRCategory(RCategoryEntity category, File imgFile);
  Future<void> removeRCategory(String id);
  Future<void> updateRCategory(RCategoryEntity category, File? imgFile);

  // Item
  Stream<List<RCategoryItemEntity>> getRCategoryItems(String categoryId);
  Future<void> createNewRCategoryItem(
      String categoryId, RCategoryItemEntity item);
  Future<void> removeRCategoryItem(String catId, String itemId);
  Future<void> updateRCategoryItem(String categoryId, RCategoryItemEntity item);
}
