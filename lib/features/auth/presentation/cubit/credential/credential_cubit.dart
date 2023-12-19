import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/sign_in_user_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/sign_up_user_usecase.dart';

part 'credential_state.dart';

class CredentialCubit extends Cubit<CredentialState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  CredentialCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.resetPasswordUseCase,
  }) : super(CredentialInitial());

  Future<void> signInUser(
      {required String email, required String password}) async {
    emit(CredentialLoading());
    try {
      await signInUseCase.call(UserEntity(email: email, password: password));
      emit(CredentialSuccess());
    } on String catch (errorMessage) {
      emit(CredentialFailure(errorMessage));
    } on SocketException {
      emit(const CredentialFailure('No Internet Connection'));
    }
  }

  Future<void> signUpUser({required UserEntity user}) async {
    emit(CredentialLoading());
    try {
      await signUpUseCase.call(user);
      emit(CredentialSuccess());
    } on String catch (errorMessage) {
      emit(CredentialFailure(errorMessage));
    } on SocketException {
      emit(const CredentialFailure('No Internet Connection'));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(CredentialLoading());
    try {
      await resetPasswordUseCase.call(email);
      emit(CredentialSuccess());
    } catch (e) {
      emit(CredentialFailure(e.toString()));
    }
  }
}
