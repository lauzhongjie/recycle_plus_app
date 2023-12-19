import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recycle_plus_app/features/learn/data/models/r_category_item_model.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';

class RCategoryModel extends RCategoryEntity {
  const RCategoryModel({
    String? id,
    String? name,
    String? imageUrl,
    List<RCategoryItemEntity>? itemList,
  }) : super(
          id: id,
          name: name,
          imageUrl: imageUrl,
          itemList: itemList,
        );

  factory RCategoryModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    var itemList = snapshot['items'] != null
        ? (snapshot['items'] as List)
            .map((item) => RCategoryItemModel.fromMap(item))
            .toList()
        : null;

    return RCategoryModel(
      id: snap.id,
      name: snapshot['name'],
      imageUrl: snapshot['imageUrl'],
      itemList: itemList,
    );
  }

  RCategoryModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<RCategoryItemEntity>? itemList,
  }) {
    return RCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      itemList: itemList ?? this.itemList,
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "imageUrl": imageUrl,
      };
}
