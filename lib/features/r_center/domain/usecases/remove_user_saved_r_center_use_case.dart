import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/domain/repositories/r_center_repository.dart';

class RemoveUserSavedRCenterUseCase {
  final RCenterRepository repository;

  RemoveUserSavedRCenterUseCase({required this.repository});

  Future<void> call(String uid, RCenterEntity rCenter) {
    return repository.removeUserSavedRCenter(uid, rCenter);
  }
}
