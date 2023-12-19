import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:recycle_plus_app/core/constants/firebase.dart';
import 'package:recycle_plus_app/features/learn/data/datasources/r_category_remote_data_source.dart';
import 'package:recycle_plus_app/features/learn/data/models/r_category_item_model.dart';
import 'package:recycle_plus_app/features/learn/data/models/r_category_model.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';

class RCategoryRemoteDataSourceImpl implements RCategoryRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  RCategoryRemoteDataSourceImpl({
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  @override
  Future<void> createNewRCategory(
      RCategoryEntity category, File imgFile) async {
    String imageUrl = await uploadImageToFirebase(imgFile, category.name!);

    RCategoryModel categoryModel = RCategoryModel(
      name: category.name,
      imageUrl: imageUrl,
      itemList: category.itemList,
    );

    final categoryData = categoryModel.toJson();

    await firebaseFirestore
        .collection(FirebaseConst.recyclingCategories)
        .add(categoryData);
  }

  @override
  Future<void> createNewRCategoryItem(
      String categoryId, RCategoryItemEntity item) async {
    final RCategoryItemModel itemModel = RCategoryItemModel(
      id: item.id,
      name: item.name,
      recyclability: item.recyclability,
      recyclingStepList: item.recyclingStepList,
    );

    final itemData = itemModel.toJson();

    await firebaseFirestore
        .collection(FirebaseConst.recyclingCategories)
        .doc(categoryId)
        .collection(FirebaseConst.recyclingCategoryItems)
        .add(itemData);
  }

  @override
  Stream<List<RCategoryEntity>> getRCategories() {
    return firebaseFirestore
        .collection(FirebaseConst.recyclingCategories)
        .snapshots()
        .asyncMap((snapshot) async {
      List<RCategoryEntity> categories = [];

      for (var doc in snapshot.docs) {
        // Fetch the items sub-collection for each category
        List<RCategoryItemEntity> itemsList = [];
        var itemsSnapshot = await doc.reference
            .collection(FirebaseConst.recyclingCategoryItems)
            .get();
        for (var itemDoc in itemsSnapshot.docs) {
          itemsList.add(RCategoryItemModel.fromSnapshot(itemDoc));
        }

        // Create the RCategoryModel with the itemsList
        RCategoryModel category = RCategoryModel.fromSnapshot(doc);
        category = category.copyWith(itemList: itemsList);
        categories.add(category);
      }
      return categories;
    });
  }

  @override
  Stream<List<RCategoryItemEntity>> getRCategoryItems(String categoryId) {
    return firebaseFirestore
        .collection(FirebaseConst.recyclingCategories)
        .doc(categoryId)
        .collection(FirebaseConst.recyclingCategoryItems)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RCategoryItemModel.fromSnapshot(doc))
            .toList());
  }

  @override
  Stream<List<RCategoryEntity>> getSingleRCategory(String id) {
    return firebaseFirestore
        .collection(FirebaseConst.recyclingCategories)
        .where(FieldPath.documentId, isEqualTo: id)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return [RCategoryModel.fromSnapshot(snapshot.docs.first)];
      } else {
        return [];
      }
    });
  }

  @override
  Future<void> removeRCategory(String id) async {
    try {
      // Fetch the document with the given ID
      DocumentSnapshot docSnapshot = await firebaseFirestore
          .collection(FirebaseConst.recyclingCategories)
          .doc(id)
          .get();

      // Check if the document exists
      if (docSnapshot.exists) {
        String imageUrl = docSnapshot.get('imageUrl');

        // Get a reference to the storage item using the imageUrl
        Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);

        // Delete the image from Firebase Storage
        await storageRef.delete();
      }

      // After deleting the image, delete the Firestore document
      await firebaseFirestore
          .collection(FirebaseConst.recyclingCategories)
          .doc(id)
          .delete();
    } catch (e) {
      print('Error removing RCategory or image: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeRCategoryItem(String catId, String itemId) async {
    try {
      await firebaseFirestore
          .collection(FirebaseConst.recyclingCategories)
          .doc(catId)
          .collection(FirebaseConst.recyclingCategoryItems)
          .doc(itemId)
          .delete();
    } catch (e) {
      print('Error removing RCategoryItem: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateRCategory(RCategoryEntity category, File? imgFile) async {
    try {
      if (category.id == null) {
        throw ArgumentError('Category ID cannot be null');
      }

      String? imageUrl;

      if (imgFile != null) {
        await deleteImageFromFirebase(category.imageUrl!);
        imageUrl = await uploadImageToFirebase(imgFile, category.name!);
      }

      // Update data map
      Map<String, dynamic> updateData = {
        'name': category.name,
      };

      if (imageUrl != null) {
        updateData['imageUrl'] = imageUrl;
      }

      await firebaseFirestore
          .collection(FirebaseConst.recyclingCategories)
          .doc(category.id)
          .update(updateData);
    } catch (e) {
      print('Error updating RCategory: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateRCategoryItem(
      String categoryId, RCategoryItemEntity item) async {
    try {
      if (item.id == null) throw ArgumentError('Item ID cannot be null');

      await firebaseFirestore
          .collection(FirebaseConst.recyclingCategories)
          .doc(categoryId)
          .collection(FirebaseConst.recyclingCategoryItems)
          .doc(item.id)
          .update({
        'name': item.name,
        'recyclability': item.recyclability,
        'recyclingStepList': item.recyclingStepList,
      });
    } catch (e) {
      print('Error updating RCategoryItem: $e');
      rethrow;
    }
  }

  Future<String> uploadImageToFirebase(File? file, String categoryName) async {
    if (file == null) throw ArgumentError("File must not be null");

    String formattedName =
        categoryName.trim().replaceAll(' ', '_').toLowerCase();
    String filePath = 'recycling_category/${formattedName}_icon.jpg';
    Reference ref = firebaseStorage.ref().child(filePath);

    final uploadTask = ref.putFile(file);
    await uploadTask.whenComplete(() {});

    final imageUrl = await ref.getDownloadURL();

    return imageUrl;
  }

  Future<void> deleteImageFromFirebase(String imageUrl) async {
    try {
      Reference ref = firebaseStorage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image from Firebase: $e');
    }
  }
}
