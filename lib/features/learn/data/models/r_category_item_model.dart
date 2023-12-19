import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';

class RCategoryItemModel extends RCategoryItemEntity {
  const RCategoryItemModel({
    String? id,
    String? name,
    bool? recyclability,
    List<String>? recyclingStepList,
  }) : super(
          id: id,
          name: name,
          recyclability: recyclability,
          recyclingStepList: recyclingStepList,
        );

factory RCategoryItemModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshotData = snap.data() as Map<String, dynamic>? ?? {};
    return RCategoryItemModel(
      id: snap.id,
      name: snapshotData['name'],
      recyclability: snapshotData['recyclability'],
      recyclingStepList: List<String>.from(snapshotData['recyclingStepList'] ?? []),
    );
  }
  
  factory RCategoryItemModel.fromMap(Map<String, dynamic> map) {
    return RCategoryItemModel(
      id: map['id'],
      name: map['name'],
      recyclability: map['recyclability'],
      recyclingStepList: List<String>.from(map['recyclingStepList'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "recyclability": recyclability,
        "recyclingStepList": recyclingStepList,
      };
}
