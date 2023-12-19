import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/create_new_scan_use_case.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/get_all_scans_use_case.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/get_all_user_scans_use_case.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/get_single_scan_use_case.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/remove_scan_use_case.dart';
import 'package:recycle_plus_app/features/scan/domain/usecases/update_scan_use_case.dart';

part 'scanning_record_state.dart';

class ScanningRecordCubit extends Cubit<ScanningRecordState> {
  final CreateNewScanUseCase createNewScanUseCase;
  final GetAllScansUseCase getAllScansUseCase;
  final GetAllUserScansUseCase getAllUserScansUseCase;
  final GetSingleScanUseCase getSingleScanUseCase;
  final RemoveScanUseCase removeScanUseCase;
  final UpdateScanUseCase updateScanUseCase;

  ScanningRecordCubit({
    required this.createNewScanUseCase,
    required this.getAllScansUseCase,
    required this.getAllUserScansUseCase,
    required this.getSingleScanUseCase,
    required this.removeScanUseCase,
    required this.updateScanUseCase,
  }) : super(ScanningRecordInitial());

  Future<void> createNewScan(ScanEntity scan, File imgFile) async {
    emit(ScanningRecordLoading());
    try {
      await createNewScanUseCase(scan, imgFile);
      getAllUserScans(scan.user!.uid!); // Refresh the list after creation
    } catch (e) {
      emit(ScanningRecordError(e.toString()));
    }
  }

  Future<void> getAllScans() async {
    emit(ScanningRecordLoading());
    try {
      final streamResponse = getAllScansUseCase.call();
      streamResponse.listen((items) {
        emit(ScanningRecordLoaded(items));
      }, onError: (e) {
        emit(ScanningRecordError(e.toString()));
      });
    } catch (e) {
      emit(ScanningRecordError(e.toString()));
    }
  }

  Future<void> getAllUserScans(String uid) async {
    emit(ScanningRecordLoading());
    try {
      final streamResponse = getAllUserScansUseCase.call(uid);
      streamResponse.listen((items) {
        emit(ScanningRecordLoaded(items));
      }, onError: (e) {
        emit(ScanningRecordError(e.toString()));
      });
    } catch (e) {
      emit(ScanningRecordError(e.toString()));
    }
  }

  Future<void> getSingleScan(String scanId) async {
    emit(ScanningRecordLoading());
    try {
      final streamResponse = getSingleScanUseCase(scanId);
      streamResponse.listen((scan) {
        emit(ScanningRecordLoaded(scan));
      }, onError: (e) {
        emit(ScanningRecordError(e.toString()));
      });
    } catch (e) {
      emit(ScanningRecordError(e.toString()));
    }
  }

  Future<void> removeScan(ScanEntity scan) async {
    emit(ScanningRecordLoading());
    try {
      await removeScanUseCase(scan);
      getAllUserScans(scan.user!.uid!); // Refresh the list after deletion
    } catch (e) {
      emit(ScanningRecordError(e.toString()));
    }
  }

  Future<void> updateScan(ScanEntity scan) async {
    emit(ScanningRecordLoading());
    try {
      await updateScanUseCase(scan);
      getAllUserScans(scan.user!.uid!); // Refresh the list after update
    } catch (e) {
      emit(ScanningRecordError(e.toString()));
    }
  }
}
