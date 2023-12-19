import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String? uid;
  final String? name;
  final String? email;
  final String? imageUrl;

  const UserModel({
    this.uid,
    this.name,
    this.email,
    this.imageUrl,
  }) : super(
          uid: uid,
          name: name,
          email: email,
          imageUrl: imageUrl,
        );

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
      uid: snapshot['uid'],
      name: snapshot['name'],
      email: snapshot['email'],
      imageUrl: snapshot['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "email": email,
        "imageUrl": imageUrl,
      };
}
