import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/get_current_uid_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/is_admin_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/is_sign_in_usecase.dart';
import 'package:recycle_plus_app/features/auth/domain/usecases/sign_out_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignOutUseCase signOutUseCase;
  final IsSignInUseCase isSignInUseCase;
  final GetCurrentUidUseCase getCurrentUidUseCase;
  final IsAdminUseCase isAdminUseCase;

  AuthCubit({
    required this.signOutUseCase,
    required this.isSignInUseCase,
    required this.getCurrentUidUseCase,
    required this.isAdminUseCase,
  }) : super(AuthInitial());

  Future<void> loggedIn() async {
    try {
      final uid = await getCurrentUidUseCase.call();
      final isAdmin = await isAdminUseCase.call(uid);
      final role = isAdmin ? "admin" : "user";
      emit(Authenticated(uid: uid, role: role));
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> loggedOut() async {
    try {
      await signOutUseCase.call();
      emit(Unauthenticated());
    } catch (_) {
      emit(Unauthenticated());
    }
  }
}
