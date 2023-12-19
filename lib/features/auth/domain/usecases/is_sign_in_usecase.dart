import 'package:recycle_plus_app/features/auth/domain/repositories/auth_firebase_repository.dart';

class IsSignInUseCase {
  final AuthFirebaseRepository repository;

  IsSignInUseCase({required this.repository});

  Future<bool> call() {
    return repository.isSignIn();
  }
}
