import 'package:recycle_plus_app/features/auth/domain/repositories/auth_firebase_repository.dart';

class ResetPasswordUseCase {
  final AuthFirebaseRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<void> call(String email) {
    return repository.resetPassword(email);
  }
}
