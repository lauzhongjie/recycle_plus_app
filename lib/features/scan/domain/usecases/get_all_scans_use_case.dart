import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/domain/repositories/scan_repository.dart';

class GetAllScansUseCase {
  final ScanRepository repository;

  GetAllScansUseCase({required this.repository});

  Stream<List<ScanEntity>> call() {
    return repository.getAllScans();
  }
}
