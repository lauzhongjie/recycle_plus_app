part of 'get_user_favorite_cubit.dart';

sealed class GetUserFavoriteRCenterState extends Equatable {
  const GetUserFavoriteRCenterState();

  @override
  List<Object> get props => [];
}

class GetUserFavoriteRCenterInitial extends GetUserFavoriteRCenterState {}

class GetUserFavoriteRCenterLoading extends GetUserFavoriteRCenterState {}

class GetUserFavoriteRCenterLoaded extends GetUserFavoriteRCenterState {
  final List<RCenterEntity> centers;
  const GetUserFavoriteRCenterLoaded(this.centers);
  @override
  List<Object> get props => [centers];
}

class GetUserFavoriteRCenterError extends GetUserFavoriteRCenterState {
  final String message;
  const GetUserFavoriteRCenterError(this.message);
  @override
  List<Object> get props => [message];
}
