// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? uid;
  final String? name;
  final String? email;
  final String? imageUrl;
  final String? password;
  final File? imageFile;

  const UserEntity({
    this.uid,
    this.name,
    this.email,
    this.imageUrl,
    this.password,
    this.imageFile,
  });

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        imageUrl,
        password,
        imageFile,
      ];

  UserEntity copyWith({
    String? uid,
    String? name,
    String? email,
    String? imageUrl,
    String? password,
    File? imageFile,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      password: password ?? this.password,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
