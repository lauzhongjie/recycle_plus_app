import 'dart:io';

import 'package:recycle_plus_app/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';
import 'package:recycle_plus_app/features/auth/domain/repositories/auth_firebase_repository.dart';

class AuthFirebaseRepositoryImpl implements AuthFirebaseRepository {
  final AuthFirebaseRemoteDataSource remoteDataSource;

  AuthFirebaseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createUser(UserEntity user) async =>
      remoteDataSource.createUser(user);

  @override
  Future<String> getCurrentUid() async => remoteDataSource.getCurrentUid();

  @override
  Stream<List<UserEntity>> getSingleUser(String uid) =>
      remoteDataSource.getSingleUser(uid);

  @override
  Stream<List<UserEntity>> getUsers(UserEntity user) =>
      remoteDataSource.getUsers(user);

  @override
  Future<bool> isSignIn() async => remoteDataSource.isSignIn();

  @override
  Future<void> signInUser(UserEntity user) async =>
      remoteDataSource.signInUser(user);

  @override
  Future<void> signOut() async => remoteDataSource.signOut();

  @override
  Future<bool> isAdmin(String uid) async => remoteDataSource.isAdmin(uid);

  @override
  Future<void> signUpUser(UserEntity user) async =>
      remoteDataSource.signUpUser(user);

  @override
  Future<void> updateUser(UserEntity user) async =>
      remoteDataSource.updateUser(user);

  @override
  Future<void> resetPassword(String email) async =>
      remoteDataSource.resetPassword(email);

  @override
  Future<String> uploadImageToFirebase(File? file, String childName) async =>
      remoteDataSource.uploadImageToFirebase(file, childName);
}
