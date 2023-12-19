part of 'scanning_record_cubit.dart';

abstract class ScanningRecordState extends Equatable {
  const ScanningRecordState();

  @override
  List<Object> get props => [];
}

class ScanningRecordInitial extends ScanningRecordState {}

class ScanningRecordLoading extends ScanningRecordState {}

class ScanningRecordLoaded extends ScanningRecordState {
  final List<ScanEntity> scans;

  const ScanningRecordLoaded(this.scans);

  @override
  List<Object> get props => [scans];
}

class ScanningRecordError extends ScanningRecordState {
  final String message;

  const ScanningRecordError(this.message);

  @override
  List<Object> get props => [message];
}
