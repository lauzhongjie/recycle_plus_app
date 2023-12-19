part of 'save_as_favorite_cubit.dart';

abstract class SaveAsFavoriteRCenterState extends Equatable {
  const SaveAsFavoriteRCenterState();

  @override
  List<Object> get props => [];
}

class SaveAsFavoriteRCenterInitial extends SaveAsFavoriteRCenterState {}

class SaveAsFavoriteRCenterLoading extends SaveAsFavoriteRCenterState {}

class SaveAsFavoriteRCenterSuccess extends SaveAsFavoriteRCenterState {}

class SaveAsFavoriteRCenterFailure extends SaveAsFavoriteRCenterState {
  final String error;

  const SaveAsFavoriteRCenterFailure(this.error);

  @override
  List<Object> get props => [error];
}
