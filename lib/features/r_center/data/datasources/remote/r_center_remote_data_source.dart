import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';

abstract class RCenterRemoteDataSource {
  // Nearby Places
  Future<List<RCenterEntity>> getNearbyPlacesWithKeyword(
      double lat, double lng, String keyword);

  // Recycling Center
  Stream<List<RCenterEntity>> getSingleRCenter(String id);
  Stream<List<RCenterEntity>> getRCenters();

  // Save as Favorite
  Future<DocumentReference> createNewRCenter(RCenterEntity rCenter);
  Future<void> saveRCenterAsFavorite(String uid, RCenterEntity rCenter);
  Stream<List<RCenterEntity>> getUserSavedRCenters(String uid);
  Future<void> removeUserSavedRCenter(String uid, RCenterEntity rCenter);
}
