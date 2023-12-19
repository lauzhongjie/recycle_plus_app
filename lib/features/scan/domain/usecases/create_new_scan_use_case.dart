import 'dart:io';

import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/domain/repositories/scan_repository.dart';

class CreateNewScanUseCase {
  final ScanRepository repository;

  CreateNewScanUseCase({required this.repository});

  Future<void> call(ScanEntity scan, File imgFile) {
    return repository.createNewScan(scan, imgFile);
  }
}
