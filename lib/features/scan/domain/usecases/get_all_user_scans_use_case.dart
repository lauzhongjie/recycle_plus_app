import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/domain/repositories/scan_repository.dart';

class GetAllUserScansUseCase {
  final ScanRepository repository;

  GetAllUserScansUseCase({required this.repository});

  Stream<List<ScanEntity>> call(String uid) {
    return repository.getAllUserScans(uid);
  }
}
