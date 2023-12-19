import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/create_new_r_category_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/get_r_categories_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/get_single_r_category_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/remove_r_category_use_case.dart';
import 'package:recycle_plus_app/features/learn/domain/usecases/update_r_category_use_case.dart';

part 'r_category_state.dart';

class RCategoryCubit extends Cubit<RCategoryState> {
  final CreateNewRCategoryUseCase createNewRCategoryUseCase;
  final GetRCategoriesUseCase getRCategoriesUseCase;
  final GetSingleRCategoryUseCase getSingleRCategoryUseCase;
  final RemoveRCategoryUseCase removeRCategoryUseCase;
  final UpdateRCategoryUseCase updateRCategoryUseCase;

  RCategoryCubit({
    required this.createNewRCategoryUseCase,
    required this.getRCategoriesUseCase,
    required this.getSingleRCategoryUseCase,
    required this.removeRCategoryUseCase,
    required this.updateRCategoryUseCase,
  }) : super(RCategoryStateInitial());

  Future<void> addNewRCategory(RCategoryEntity category, File imgFile) async {
    emit(RCategoryStateLoading());
    try {
      await createNewRCategoryUseCase(category, imgFile);
      getRCategories();
    } catch (e) {
      emit(RCategoryStateError(e.toString()));
    }
  }

  Future<void> getRCategories() async {
    emit(RCategoryStateLoading());
    try {
      final streamResponse = getRCategoriesUseCase.call();
      streamResponse.listen((cat) {
        emit(RCategoryStateSuccess(cat));
      });
    } on SocketException catch (e) {
      emit(RCategoryStateError(e.toString()));
    } catch (e) {
      emit(RCategoryStateError(e.toString()));
    }
  }

  Future<void> getSingleRCategory({required String id}) async {
    emit(RCategoryStateLoading());
    try {
      final streamResponse = getSingleRCategoryUseCase.call(id);
      await for (var cat in streamResponse) {
        if (cat.isNotEmpty) {
          emit(RCategoryStateSuccess(cat));
        } else {
          const RCategoryStateError('Failed to get single recycling category.');
        }
      }
    } on SocketException catch (e) {
      emit(RCategoryStateError(e.toString()));
    } catch (e) {
      emit(RCategoryStateError(e.toString()));
    }
  }

  Future<void> removeRCategory(String id) async {
    emit(RCategoryStateLoading());
    try {
      await removeRCategoryUseCase(id);
      getRCategories();
    } catch (e) {
      emit(RCategoryStateError(e.toString()));
    }
  }

  Future<void> updateRCategory(RCategoryEntity category, File? imgFile) async {
    emit(RCategoryStateLoading());
    try {
      await updateRCategoryUseCase(category, imgFile);
      getRCategories();
    } catch (e) {
      emit(RCategoryStateError(e.toString()));
    }
  }
}
