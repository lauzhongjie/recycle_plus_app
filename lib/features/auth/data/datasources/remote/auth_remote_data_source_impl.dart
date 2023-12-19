import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:recycle_plus_app/core/constants/firebase.dart';
import 'package:recycle_plus_app/core/widgets/toast.dart';
import 'package:recycle_plus_app/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:recycle_plus_app/features/auth/data/models/user_model.dart';
import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';

class AuthFirebaseRemoteDataSourceImpl implements AuthFirebaseRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;

  AuthFirebaseRemoteDataSourceImpl({
    required this.firebaseFirestore,
    required this.firebaseAuth,
    required this.firebaseStorage,
  });

  @override
  Future<void> createUser(UserEntity user) async {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);

    final uid = await getCurrentUid();
    const defaultImageIcon =
        "https://firebasestorage.googleapis.com/v0/b/final-year-project-3ec21.appspot.com/o/profile_icon%2F21.png?alt=media&token=a9aeaed5-f473-4c2e-86c0-7c4a7ee76f07";

    userCollection.doc(uid).get().then(
      (userDoc) {
        final newUser = UserModel(
          uid: uid,
          name: user.name,
          email: user.email,
          imageUrl: defaultImageIcon,
        ).toJson();

        if (!userDoc.exists) {
          userCollection.doc(uid).set(newUser);
        } else {
          userCollection.doc(uid).update(newUser);
        }
      },
    ).catchError((error) {
      toast("Some error occur");
    });
  }

  @override
  Future<String> getCurrentUid() async => firebaseAuth.currentUser!.uid;

  @override
  Stream<List<UserEntity>> getSingleUser(String uid) {
    final userCollection = firebaseFirestore
        .collection(FirebaseConst.users)
        .where("uid", isEqualTo: uid)
        .limit(1);

    return userCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList());
  }

  @override
  Stream<List<UserEntity>> getUsers(UserEntity user) {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);

    return userCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList());
  }

  @override
  Future<bool> isSignIn() async => firebaseAuth.currentUser?.uid != null;

  @override
  Future<void> signInUser(UserEntity user) async {
    if (user.email!.isEmpty || user.password!.isEmpty) {
      throw 'Fields cannot be empty';
    }

    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: user.email!, password: user.password!);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "user-not-found":
          errorMessage = 'User not found';
          break;
        case "wrong-password":
          errorMessage = 'Invalid email or password';
          break;
        case "invalid-email":
          errorMessage = 'Invalid email format';
          break;
        case "user-disabled":
          errorMessage = 'User has been disabled';
          break;
        default:
          errorMessage = 'Invalid email or password';
      }
      throw errorMessage;
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<void> signUpUser(UserEntity user) async {
    if (user.email!.isEmpty || user.password!.isEmpty || user.name!.isEmpty) {
      throw 'Fields cannot be empty';
    }

    try {
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: user.email!, password: user.password!)
          .then((value) async {
        if (value.user?.uid != null) {
          createUser(user);
        }
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "email-already-in-use":
          errorMessage = 'Email address is already taken';
          break;
        case "invalid-email":
          errorMessage = 'Invalid email format';
          break;
        case "weak-password":
          errorMessage = 'Password should be at least 6 characters';
          break;
        default:
          errorMessage = 'An error occurred. Please try again later.';
      }
      throw errorMessage;
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final userCollection = firebaseFirestore.collection(FirebaseConst.users);
    Map<String, dynamic> userInformation = {};

    if (user.name != "" && user.name != null) {
      userInformation['name'] = user.name;
    }

    if (user.imageUrl != "" && user.imageUrl != null) {
      userInformation['imageUrl'] = user.imageUrl;
    }

    userCollection.doc(user.uid).update(userInformation);
  }

  @override
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      throw 'Email cannot be empty';
    }

    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "invalid-email":
          errorMessage = 'Invalid email format';
          break;
        case "user-not-found":
          errorMessage = 'User not found for this email';
          break;
        default:
          errorMessage = 'Failed to send password reset email: ${e.message}';
      }
      throw errorMessage;
    } catch (e) {
      throw 'An error occurred while trying to send password reset email: $e';
    }
  }

  @override
  Future<String> uploadImageToFirebase(File? file, String childName) async {
    Reference ref = firebaseStorage
        .ref()
        .child(childName)
        .child(firebaseAuth.currentUser!.uid);

    final uploadTask = ref.putFile(file!);

    final imageUrl =
        (await uploadTask.whenComplete(() {})).ref.getDownloadURL();

    return await imageUrl;
  }

  @override
  Future<bool> isAdmin(String uid) async {
    final adminCollection = firebaseFirestore
        .collection(FirebaseConst.admin)
        .where("uid", isEqualTo: uid)
        .limit(1);

    final querySnapshot = await adminCollection.get();

    return querySnapshot.docs.isNotEmpty;
  }
}
