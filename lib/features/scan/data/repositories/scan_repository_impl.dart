import 'dart:io';

import 'package:recycle_plus_app/features/scan/data/datasources/scan_remote_data_source.dart';
import 'package:recycle_plus_app/features/scan/data/models/scan_model.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/domain/repositories/scan_repository.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource scanRemoteDataSource;

  ScanRepositoryImpl({required this.scanRemoteDataSource});

  @override
  Future<void> createNewScan(ScanEntity scan, File imgFile) async =>
      scanRemoteDataSource.createNewScan(scan, imgFile);

  @override
  Stream<List<ScanModel>> getAllScans() => scanRemoteDataSource.getAllScans();

  @override
  Stream<List<ScanModel>> getAllUserScans(String uid) => scanRemoteDataSource.getAllUserScans(uid);

  @override
  Stream<List<ScanModel>> getSingleScan(String id) =>
      scanRemoteDataSource.getSingleScan(id);

  @override
  Future<void> removeScan(ScanEntity scan) async =>
      scanRemoteDataSource.removeScan(scan);

  @override
  Future<void> updateScan(ScanEntity scan) =>
      scanRemoteDataSource.updateScan(scan);
}
