import 'dart:io';

import 'package:recycle_plus_app/features/learn/data/datasources/r_category_remote_data_source.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/repositories/r_category_repository.dart';

class RCategoryRepositoryImpl implements RCategoryRepository {
  final RCategoryRemoteDataSource rCategoryRemoteDataSource;

  RCategoryRepositoryImpl({required this.rCategoryRemoteDataSource});

  @override
  Future<void> createNewRCategory(RCategoryEntity category, File imgFile) async =>
      rCategoryRemoteDataSource.createNewRCategory(category, imgFile);

  @override
  Future<void> createNewRCategoryItem(
          String categoryId, RCategoryItemEntity item) async =>
      rCategoryRemoteDataSource.createNewRCategoryItem(categoryId, item);

  @override
  Stream<List<RCategoryEntity>> getRCategories() =>
      rCategoryRemoteDataSource.getRCategories();

  @override
  Stream<List<RCategoryItemEntity>> getRCategoryItems(String categoryId) =>
      rCategoryRemoteDataSource.getRCategoryItems(categoryId);

  @override
  Stream<List<RCategoryEntity>> getSingleRCategory(String id) =>
      rCategoryRemoteDataSource.getSingleRCategory(id);

  @override
  Future<void> removeRCategory(String id) async =>
      rCategoryRemoteDataSource.removeRCategory(id);

  @override
  Future<void> removeRCategoryItem(String catId, String itemId) async =>
      rCategoryRemoteDataSource.removeRCategoryItem(catId, itemId);

  @override
  Future<void> updateRCategory(RCategoryEntity category, File? imgFile) async =>
      rCategoryRemoteDataSource.updateRCategory(category, imgFile);

  @override
  Future<void> updateRCategoryItem(
          String categoryId, RCategoryItemEntity item) async =>
      rCategoryRemoteDataSource.updateRCategoryItem(categoryId, item);
}
