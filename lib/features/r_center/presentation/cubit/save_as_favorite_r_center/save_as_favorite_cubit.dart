import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/save_r_center_as_favorite_use_case.dart';

part 'save_as_favorite_state.dart';

class SaveAsFavoriteRCenterCubit extends Cubit<SaveAsFavoriteRCenterState> {
  final SaveRCenterAsFavoriteUseCase saveAsFavoriteUseCase;

  SaveAsFavoriteRCenterCubit({required this.saveAsFavoriteUseCase})
      : super(SaveAsFavoriteRCenterInitial());

  Future<void> saveAsFavorite(String uid, RCenterEntity rCenter) async {
    try {
      emit(SaveAsFavoriteRCenterLoading());
      await saveAsFavoriteUseCase.call(uid, rCenter);
      emit(SaveAsFavoriteRCenterSuccess());
    } catch (e) {
      emit(SaveAsFavoriteRCenterFailure(e.toString()));
    }
  }
}
