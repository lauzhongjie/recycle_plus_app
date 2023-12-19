import 'dart:io';

import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthFirebaseRemoteDataSource {
  // Credential
  Future<void> signInUser(UserEntity user);
  Future<void> signUpUser(UserEntity user);
  Future<bool> isSignIn();
  Future<void> signOut();
  Future<bool> isAdmin(String uid);

  // User
  Stream<List<UserEntity>> getUsers(UserEntity user);
  Stream<List<UserEntity>> getSingleUser(String uid);
  Future<String> getCurrentUid();
  Future<void> createUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Future<void> resetPassword(String email);

  // Cloud Storage
  Future<String> uploadImageToFirebase(File? file, String childName);
}
