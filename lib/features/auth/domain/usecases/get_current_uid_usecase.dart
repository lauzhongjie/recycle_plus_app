import 'package:recycle_plus_app/features/auth/domain/repositories/auth_firebase_repository.dart';

class GetCurrentUidUseCase {
  final AuthFirebaseRepository repository;

  GetCurrentUidUseCase({required this.repository});

  Future<String> call() {
    return repository.getCurrentUid();
  }
}