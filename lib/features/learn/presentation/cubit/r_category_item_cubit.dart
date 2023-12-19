import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/create_new_r_category_item_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/get_r_category_items_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/remove_r_category_item_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/update_r_category_item_use_case.dart';

part 'r_category_item_state.dart';

class RCategoryItemCubit extends Cubit<RCategoryItemState> {
  final CreateNewRCategoryItemUseCase createNewRCategoryItemUseCase;
  final GetRCategoryItemsUseCase getRCategoryItemsUseCase;
  final RemoveRCategoryItemUseCase removeRCategoryItemUseCase;
  final UpdateRCategoryItemUseCase updateRCategoryItemUseCase;

  RCategoryItemCubit({
    required this.createNewRCategoryItemUseCase,
    required this.getRCategoryItemsUseCase,
    required this.removeRCategoryItemUseCase,
    required this.updateRCategoryItemUseCase,
  }) : super(RCategoryItemInitial());

  Future<void> addNewRCategoryItem(
      String categoryId, RCategoryItemEntity item) async {
    emit(RCategoryItemLoading());
    try {
      await createNewRCategoryItemUseCase(categoryId, item);
      getRCategoryItems(categoryId: categoryId);
    } catch (e) {
      emit(RCategoryItemError(e.toString()));
    }
  }

  Future<void> getRCategoryItems({required String categoryId}) async {
    emit(RCategoryItemLoading());
    try {
      final streamResponse = getRCategoryItemsUseCase.call(categoryId);
      streamResponse.listen((items) {
        emit(RCategoryItemSuccess(items));
      }, onError: (e) {
        emit(RCategoryItemError(e.toString()));
      });
    } catch (e) {
      emit(RCategoryItemError(e.toString()));
    }
  }

  Future<void> updateRCategoryItem(
      String catId, RCategoryItemEntity item) async {
    emit(RCategoryItemLoading());
    try {
      await updateRCategoryItemUseCase(catId, item);
      getRCategoryItems(categoryId: catId);
    } catch (e) {
      emit(RCategoryItemError(e.toString()));
    }
  }

  Future<void> removeRCategoryItem(String catId, String itemId) async {
    emit(RCategoryItemLoading());
    try {
      await removeRCategoryItemUseCase(catId, itemId);
      getRCategoryItems(categoryId: catId);
    } catch (e) {
      emit(RCategoryItemError(e.toString()));
    }
  }
}
