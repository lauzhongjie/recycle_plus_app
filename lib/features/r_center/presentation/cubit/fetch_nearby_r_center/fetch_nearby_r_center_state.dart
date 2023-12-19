part of 'fetch_nearby_r_center_cubit.dart';

abstract class FetchNearbyRCenterState extends Equatable {
  const FetchNearbyRCenterState();
}

class RCenterInitial extends FetchNearbyRCenterState {
  @override
  List<Object> get props => [];
}

class FetchNearbyRCenterLoading extends FetchNearbyRCenterState {
  @override
  List<Object> get props => [];
}

class FetchNearbyRCenterLoaded extends FetchNearbyRCenterState {
  final List<RCenterEntity> centers;

  const FetchNearbyRCenterLoaded({required this.centers});

  @override
  List<Object> get props => [centers];
}

class FetchNearbyRCenterFailure extends FetchNearbyRCenterState {
  @override
  List<Object> get props => [];
}
