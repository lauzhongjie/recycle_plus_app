import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/domain/repositories/scan_repository.dart';

class GetSingleScanUseCase {
  final ScanRepository repository;

  GetSingleScanUseCase({required this.repository});

  Stream<List<ScanEntity>> call(String id) {
    return repository.getSingleScan(id);
  }
}
