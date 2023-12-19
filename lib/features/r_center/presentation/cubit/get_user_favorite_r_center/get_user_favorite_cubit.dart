import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/get_user_saved_r_centers_use_case.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/remove_user_saved_r_center_use_case.dart';

part 'get_user_favorite_state.dart';

class GetUserFavoriteRCenterCubit extends Cubit<GetUserFavoriteRCenterState> {
  final GetUserSavedRCentersUseCase getUserSavedRCentersUseCase;
  final RemoveUserSavedRCenterUseCase removeUserSavedRCenterUseCase;

  GetUserFavoriteRCenterCubit({
    required this.getUserSavedRCentersUseCase,
    required this.removeUserSavedRCenterUseCase,
  }) : super(GetUserFavoriteRCenterInitial());

  Future<void> fetchUserFavoritesRCenter(String uid) async {
    emit(GetUserFavoriteRCenterLoading());
    try {
      final centersStream = getUserSavedRCentersUseCase.call(uid);
      await for (final centers in centersStream) {
        emit(GetUserFavoriteRCenterLoaded(centers));
      }
    } catch (e) {
      emit(GetUserFavoriteRCenterError(e.toString()));
    }
  }

  Future<void> removeFromFavoriteRCenter(
      String uid, RCenterEntity rCenter) async {
    try {
      await removeUserSavedRCenterUseCase.call(uid, rCenter);
    } catch (e) {
      emit(GetUserFavoriteRCenterError(e.toString()));
    }
  }
}
