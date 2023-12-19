import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';
import 'package:recycle_plus_app/features/auth/domain/repositories/auth_firebase_repository.dart';

class SignUpUseCase {
  final AuthFirebaseRepository repository;

  SignUpUseCase({required this.repository});

  Future<void> call(UserEntity user) {
    return repository.signUpUser(user);
  }
}
