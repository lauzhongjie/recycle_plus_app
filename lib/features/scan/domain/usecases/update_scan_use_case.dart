import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/domain/repositories/scan_repository.dart';

class UpdateScanUseCase {
  final ScanRepository repository;

  UpdateScanUseCase({required this.repository});

  Future<void> call(ScanEntity scan) {
    return repository.updateScan(scan);
  }
}
