import 'dart:io';

import 'package:recycle_plus_app/features/auth/domain/repositories/auth_firebase_repository.dart';

class UploadImageToFirebaseUseCase {
  final AuthFirebaseRepository repository;

  UploadImageToFirebaseUseCase({required this.repository});

  Future<String> call(File file, String childName) {
    return repository.uploadImageToFirebase(file, childName);
  }
}
