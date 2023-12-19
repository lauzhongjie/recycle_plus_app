import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/domain/repositories/r_center_repository.dart';

class GetRCentersUseCase {
  final RCenterRepository repository;

  GetRCentersUseCase({required this.repository});

  Stream<List<RCenterEntity>> call(RCenterEntity rCenter) {
    return repository.getRCenters();
  }
}
