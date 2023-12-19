import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:recycle_plus_app/core/constants/firebase.dart';
import 'package:recycle_plus_app/features/scan/data/datasources/scan_remote_data_source.dart';
import 'package:recycle_plus_app/features/scan/data/models/scan_model.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';

class ScanRemoteDataSourceImpl implements ScanRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ScanRemoteDataSourceImpl({
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  @override
  Future<void> createNewScan(ScanEntity scan, File imgFile) async {
    try {
      // Convert to model
      ScanModel scanModel = ScanModel.fromEntity(scan);

      // Upload the image
      String userFolder = scan.user?.uid ?? 'unknown_user';
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = '$userFolder/$timeStamp.jpg';
      String imageUrl = await uploadImageToFirebase(imgFile, filePath);

      // Add image URL to scan JSON
      Map<String, dynamic> scanJson = scanModel.toJson();
      scanJson['imageUrl'] = imageUrl;

      // Save the scan to Firestore
      await firebaseFirestore.collection(FirebaseConst.scans).add(scanJson);
    } catch (e) {
      print(e);
    }
  }

  @override
  Stream<List<ScanModel>> getAllScans() {
    return firebaseFirestore
        .collection(FirebaseConst.scans)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Future<ScanModel>> futures =
          snapshot.docs.map((doc) => ScanModel.fromSnapshot(doc)).toList();
      return await Future.wait(futures);
    });
  }

  @override
  Stream<List<ScanModel>> getAllUserScans(String uid) {
    // Create a DocumentReference to the user's document
    DocumentReference userRef = firebaseFirestore.collection('users').doc(uid);

    return firebaseFirestore
        .collection(FirebaseConst.scans)
        .where('user', isEqualTo: userRef)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Future<ScanModel>> futures =
          snapshot.docs.map((doc) => ScanModel.fromSnapshot(doc)).toList();
      return await Future.wait(futures);
    });
  }

  @override
  Stream<List<ScanModel>> getSingleScan(String id) {
    return firebaseFirestore
        .collection('scans')
        .doc(id)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists) return [];
      return [await ScanModel.fromSnapshot(snapshot)];
    });
  }

  @override
  Future<void> removeScan(ScanEntity scan) async {
    if (scan.id == null) throw ArgumentError('Scan ID cannot be null');

    // Delete the scan document
    await firebaseFirestore
        .collection(FirebaseConst.scans)
        .doc(scan.id)
        .delete();

    // Delete the image if URL exists
    if (scan.imageUrl != null && scan.imageUrl!.isNotEmpty) {
      await deleteImageFromFirebase(scan.imageUrl!);
    }
  }

  @override
  Future<void> updateScan(ScanEntity scan) async {
    if (scan.id == null) throw ArgumentError('Scan ID cannot be null');

    DocumentReference docRef =
        firebaseFirestore.collection(FirebaseConst.scans).doc(scan.id);
    Map<String, dynamic> scanJson = (scan as ScanModel).toJson();

    await docRef.set(scanJson, SetOptions(merge: true));
  }

  Future<String> uploadImageToFirebase(File? file, String fileName) async {
    if (file == null) throw ArgumentError("File must not be null");

    String formattedName = fileName.trim().replaceAll(' ', '_').toLowerCase();
    String filePath = 'scanning/$formattedName';
    Reference ref = firebaseStorage.ref().child(filePath);

    final uploadTask = ref.putFile(file);
    await uploadTask.whenComplete(() {});

    final imageUrl = await ref.getDownloadURL();

    return imageUrl;
  }

  Future<void> deleteImageFromFirebase(String imageUrl) async {
    try {
      Reference ref = firebaseStorage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image from Firebase: $e');
    }
  }
}
