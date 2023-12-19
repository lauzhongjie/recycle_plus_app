import 'package:recycle_plus_app/features/auth/domain/repositories/auth_firebase_repository.dart';

class SignOutUseCase {
  final AuthFirebaseRepository repository;

  SignOutUseCase({required this.repository});

  Future<void> call() {
    return repository.signOut();
  }
}
