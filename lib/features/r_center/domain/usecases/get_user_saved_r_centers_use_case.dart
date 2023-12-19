import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/domain/repositories/r_center_repository.dart';

class GetUserSavedRCentersUseCase {
  final RCenterRepository repository;

  GetUserSavedRCentersUseCase({required this.repository});

  Stream<List<RCenterEntity>> call(String uid) {
    return repository.getUserSavedRCenters(uid);
  }
}
