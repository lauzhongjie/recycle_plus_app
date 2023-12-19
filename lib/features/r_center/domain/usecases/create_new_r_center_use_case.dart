import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/domain/repositories/r_center_repository.dart';

class CreateNewRCenterUseCase {
  final RCenterRepository repository;

  CreateNewRCenterUseCase({required this.repository});

  Future<DocumentReference> call(RCenterEntity rCenter) {
    return repository.createNewRCenter(rCenter);
  }
}
