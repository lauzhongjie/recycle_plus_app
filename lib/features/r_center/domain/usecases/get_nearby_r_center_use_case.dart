import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/domain/repositories/r_center_repository.dart';

class GetNearbyRCenterUseCase {
  final RCenterRepository repository;

  GetNearbyRCenterUseCase({required this.repository});

  Future<List<RCenterEntity>> call(double lat, double lng, String keyword) {
    return repository.getNearbyPlacesWithKeyword(lat, lng, keyword);
  }
}
