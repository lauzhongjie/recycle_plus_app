import 'dart:io';

import 'package:recycle_plus_app/features/scan/data/models/scan_model.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';

abstract class ScanRepository {
  Stream<List<ScanModel>> getSingleScan(String id);
  Stream<List<ScanModel>> getAllScans();
  Stream<List<ScanModel>> getAllUserScans(String uid);
  Future<void> createNewScan(ScanEntity scan, File imgFile);
  Future<void> removeScan(ScanEntity scan);
  Future<void> updateScan(ScanEntity scan);
}
