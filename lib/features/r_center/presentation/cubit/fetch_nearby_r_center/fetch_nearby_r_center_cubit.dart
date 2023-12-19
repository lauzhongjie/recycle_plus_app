import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/domain/usecases/get_nearby_r_center_use_case.dart';

part 'fetch_nearby_r_center_state.dart';

class FetchNearbyRCenterCubit extends Cubit<FetchNearbyRCenterState> {
  final GetNearbyRCenterUseCase getNearbyRCenterUseCase;

  FetchNearbyRCenterCubit({
    required this.getNearbyRCenterUseCase,
  }) : super(RCenterInitial());

  Future<void> getNearbyRCenter({
    required double lat,
    required double lng,
    required String keyword,
  }) async {
    emit(FetchNearbyRCenterLoading());
    try {
      final centers = await getNearbyRCenterUseCase.call(lat, lng, keyword);
      emit(FetchNearbyRCenterLoaded(centers: centers));
    } on SocketException catch (_) {
      emit(FetchNearbyRCenterFailure());
    } catch (e) {
      emit(FetchNearbyRCenterFailure());
      print(e);
    }
  }
}
