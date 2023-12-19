import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recycle_plus_app/features/auth/data/models/user_model.dart';
import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';
import 'package:recycle_plus_app/features/scan/data/models/detected_object_model.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';

// Utility function to convert a DocumentReference to a UserEntity
Future<UserEntity> _refToUserEntity(DocumentReference ref) async {
  DocumentSnapshot snapshot = await ref.get();
  return UserModel.fromSnapshot(snapshot);
}

class ScanModel extends ScanEntity {
  const ScanModel({
    super.id,
    super.user,
    super.detectedObjectList,
    super.imageUrl,
    super.scanDate,
  });

  // Constructor for converting ScanEntity to ScanModel
  ScanModel.fromEntity(ScanEntity scanEntity)
      : super(
          id: scanEntity.id,
          user: scanEntity.user,
          detectedObjectList: scanEntity.detectedObjectList,
          imageUrl: scanEntity.imageUrl,
          scanDate: scanEntity.scanDate,
        );

  // Factory method to create ScanModel from Firestore snapshot
  static Future<ScanModel> fromSnapshot(DocumentSnapshot snap) async {
    final Map<String, dynamic> snapshot = snap.data() as Map<String, dynamic>;

    // Convert user reference to UserEntity
    final UserEntity? userEntity = snapshot['user'] != null
        ? await _refToUserEntity(snapshot['user'] as DocumentReference)
        : null;

    // Asynchronously convert detectedObjectList to a list of DetectedObjectModel
    List<DetectedObjectModel> detectedObjects = [];
    if (snapshot['detectedObjectList'] != null) {
      detectedObjects = await Future.wait(
        (snapshot['detectedObjectList'] as List)
            .map((detectedObjectData) async {
          DocumentReference itemRef = detectedObjectData['itemRef'];
          DocumentReference categoryRef = detectedObjectData['categoryRef'];
          int count = detectedObjectData['count'];

          // Fetch the documents for item and category
          DocumentSnapshot itemSnap = await itemRef.get();
          DocumentSnapshot categorySnap = await categoryRef.get();

          // Use DetectedObjectModel.fromSnapshot to create DetectedObjectModel
          return await DetectedObjectModel.fromSnapshot(
            itemSnap,
            categorySnap,
            count,
          );
        }),
      );
    }

    return ScanModel(
      id: snap.id,
      user: userEntity,
      detectedObjectList: detectedObjects,
      imageUrl: snapshot['imageUrl'] as String?,
      scanDate: (snapshot['scanDate'] as Timestamp?)?.toDate(),
    );
  }

  // Method to convert ScanModel to Firestore JSON with document references
  Map<String, dynamic> toJson() {
    return {
      "user": user != null
          ? FirebaseFirestore.instance.collection('users').doc(user!.uid)
          : null,
      "detectedObjectList": detectedObjectList!
          .map((detectedObject) =>
              (DetectedObjectModel.fromEntity(detectedObject)).toJson())
          .toList(),
      "imageUrl": imageUrl,
      "scanDate": scanDate != null ? Timestamp.fromDate(scanDate!) : null,
    };
  }
}
