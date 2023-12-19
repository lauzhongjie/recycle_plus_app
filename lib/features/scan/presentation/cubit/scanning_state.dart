part of 'scanning_cubit.dart';

abstract class ScanningState extends Equatable {
  const ScanningState();

  @override
  List<Object> get props => [];
}

class ScanningInitial extends ScanningState {}

class ScanningLoading extends ScanningState {}

class ScanningLoaded extends ScanningState {
  final Map<String, dynamic> scanResults;

  const ScanningLoaded(this.scanResults);

  @override
  List<Object> get props => [scanResults];
}

class ScanningFailure extends ScanningState {}
