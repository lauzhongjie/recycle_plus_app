import 'package:recycle_plus_app/features/auth/domain/repositories/auth_firebase_repository.dart';

class IsAdminUseCase {
  final AuthFirebaseRepository repository;

  IsAdminUseCase({required this.repository});

  Future<bool> call(String uid) {
    return repository.isAdmin(uid);
  }
}
