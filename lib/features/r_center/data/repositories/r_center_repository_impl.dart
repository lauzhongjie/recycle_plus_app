import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recycle_plus_app/features/r_center/data/datasources/remote/r_center_remote_data_source.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/domain/repositories/r_center_repository.dart';

class RCenterRepositoryImpl implements RCenterRepository {
  final RCenterRemoteDataSource rCenterRemoteDataSource;

  RCenterRepositoryImpl({required this.rCenterRemoteDataSource});

  @override
  Future<List<RCenterEntity>> getNearbyPlacesWithKeyword(
          double lat, double lng, String keyword) async =>
      rCenterRemoteDataSource.getNearbyPlacesWithKeyword(lat, lng, keyword);

  @override
  Future<DocumentReference> createNewRCenter(RCenterEntity rCenter) async =>
      rCenterRemoteDataSource.createNewRCenter(rCenter);

  @override
  Future<void> saveRCenterAsFavorite(String uid, RCenterEntity rCenter) async =>
      rCenterRemoteDataSource.saveRCenterAsFavorite(uid, rCenter);

  @override
  Stream<List<RCenterEntity>> getSingleRCenter(String id) =>
      rCenterRemoteDataSource.getSingleRCenter(id);

  @override
  Stream<List<RCenterEntity>> getRCenters() =>
      rCenterRemoteDataSource.getRCenters();

  @override
  Stream<List<RCenterEntity>> getUserSavedRCenters(String uid) =>
      rCenterRemoteDataSource.getUserSavedRCenters(uid);

  @override
  Future<void> removeUserSavedRCenter(
          String uid, RCenterEntity rCenter) async =>
      rCenterRemoteDataSource.removeUserSavedRCenter(uid, rCenter);
}
