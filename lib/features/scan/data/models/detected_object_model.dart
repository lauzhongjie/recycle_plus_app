import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recycle_plus_app/core/constants/firebase.dart';
import 'package:recycle_plus_app/features/learn/data/models/r_category_item_model.dart';
import 'package:recycle_plus_app/features/learn/data/models/r_category_model.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/detected_object_entity.dart';

class DetectedObjectModel extends DetectedObjectEntity {
  DetectedObjectModel({
    required super.item,
    required super.category,
    required super.count,
  });

  // Constructor for converting ScanEntity to ScanModel
  DetectedObjectModel.fromEntity(DetectedObjectEntity detectedObjectEntity)
      : super(
          item: detectedObjectEntity.item,
          category: detectedObjectEntity.category,
          count: detectedObjectEntity.count,
        );

  // Factory method to create ScanModel from Firestore snapshot
  static Future<DetectedObjectModel> fromSnapshot(DocumentSnapshot itemSnapshot,
      DocumentSnapshot categorySnapshot, int count) async {
    RCategoryItemEntity item = RCategoryItemModel.fromSnapshot(itemSnapshot);
    RCategoryEntity category = RCategoryModel.fromSnapshot(categorySnapshot);

    // Create and return the DetectedObjectModel
    return DetectedObjectModel(
      item: item,
      category: category,
      count: count,
    );
  }

  // Method to convert ScanModel to Firestore JSON with document references
  Map<String, dynamic> toJson() {
    return {
      "itemRef": FirebaseFirestore.instance
          .collection(FirebaseConst.recyclingCategories)
          .doc(category.id)
          .collection(FirebaseConst.recyclingCategoryItems)
          .doc(item.id),
      "categoryRef": FirebaseFirestore.instance
          .collection(FirebaseConst.recyclingCategories)
          .doc(category.id),
      "count": count,
    };
  }
}
