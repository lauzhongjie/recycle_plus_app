import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/domain/repositories/r_center_repository.dart';

class SaveRCenterAsFavoriteUseCase {
  final RCenterRepository repository;

  SaveRCenterAsFavoriteUseCase({required this.repository});

  Future<void> call(String uid, RCenterEntity rCenter) {
    return repository.saveRCenterAsFavorite(uid, rCenter);
  }
}
