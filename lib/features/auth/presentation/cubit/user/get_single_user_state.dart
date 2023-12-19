part of 'get_single_user_cubit.dart';

sealed class GetSingleUserState extends Equatable {
  const GetSingleUserState();
}

final class GetSingleUserInitial extends GetSingleUserState {
  @override
  List<Object> get props => [];
}

final class GetSingleUserLoading extends GetSingleUserState {
  @override
  List<Object> get props => [];
}

final class GetSingleUserLoaded extends GetSingleUserState {
  final UserEntity user;

  const GetSingleUserLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

final class GetSingleUserFailure extends GetSingleUserState {
  @override
  List<Object> get props => [];
}

class GetSingleUserDispose extends GetSingleUserState {
  @override
  List<Object?> get props => [];
}
