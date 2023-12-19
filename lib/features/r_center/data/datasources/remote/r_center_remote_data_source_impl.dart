import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:recycle_plus_app/core/constants/apis.dart';
import 'package:recycle_plus_app/core/constants/firebase.dart';
import 'package:recycle_plus_app/core/constants/urls.dart';
import 'package:recycle_plus_app/features/r_center/data/datasources/remote/r_center_remote_data_source.dart';
import 'package:recycle_plus_app/features/r_center/data/models/day_opening_hours_model.dart';
import 'package:recycle_plus_app/features/r_center/data/models/r_center_model.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';

class RCenterRemoteDataSourceImpl implements RCenterRemoteDataSource {
  final FirebaseFirestore firebaseFirestore;

  RCenterRemoteDataSourceImpl({required this.firebaseFirestore});

  final String apiKey = APIConst.googleMapAPIKey;

  //------------
  // HTTP CALLS
  //------------
  @override
  Future<List<RCenterEntity>> getNearbyPlacesWithKeyword(
      double lat, double lng, String keyword) async {
    const String baseUrl = UrlConst.googlePlaceNearbySearchBaseUrl;
    final String location = '$lat,$lng';
    const String radius = '5000';
    final Uri uri = Uri.parse(
        '$baseUrl?location=$location&radius=$radius&keyword=$keyword&key=$apiKey');

    try {
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // If success get nearby places from API,
        // Pass to another link to get the place details using place id.

        final List<dynamic> places = data['results'];
        List<RCenterEntity> recyclingCenters = [];

        // Add to a list of RCenterEntity and return the list

        for (var placeJson in places) {
          final String placeId = placeJson['place_id'];

          // Obtain place details
          final Map<String, dynamic> detailsJson =
              await getPlaceDetails(placeId);

          // Obtain direction details
          final Map<String, dynamic> directionsJson =
              await getDistanceAndEstimatedTime(
            lat,
            lng,
            detailsJson['geometry']['location']['lat'],
            detailsJson['geometry']['location']['lng'],
          );
          
          final RCenterModel recyclingCenter =
              RCenterModel.fromJson(detailsJson, directionsJson);

          recyclingCenters.add(recyclingCenter);
        }

        return recyclingCenters;
      } else {
        throw Exception('Failed to load nearby places.');
      }
    } catch (e) {
      print('An error occurred: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    const String baseUrl = UrlConst.googlePlaceDetailsBaseUrl;
    final Uri uri = Uri.parse('$baseUrl?placeid=$placeId&key=$apiKey');

    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['result'];
    } else {
      throw Exception('Failed to load place details.');
    }
  }

  Future<Map<String, dynamic>> getDistanceAndEstimatedTime(double userLat,
      double userLng, double destinationLat, double destinationLng) async {
    const String baseUrl = UrlConst.googlePlaceDirectionsBaseUrl;
    final String origin = '$userLat,$userLng';
    final String destination = '$destinationLat,$destinationLng';
    final Uri uri = Uri.parse(
        '$baseUrl?origin=$origin&destination=$destination&key=$apiKey');

    final http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> routes = data['routes'];

      if (routes.isNotEmpty) {
        final Map<String, dynamic> leg = routes[0]['legs'][0];
        final double distanceInMeters = leg['distance']['value'].toDouble();
        final int durationSeconds = leg['duration']['value'];
        final double estimatedArrivalTime =
            durationSeconds / 60.0; // Convert to minutes

        return {
          'distance': distanceInMeters,
          'estimatedTime': estimatedArrivalTime
        };
      } else {
        throw Exception('No routes found');
      }
    } else {
      throw Exception('Failed to load directions');
    }
  }

  //------------
  // FIREBASE
  //------------
  @override
  Future<DocumentReference> createNewRCenter(RCenterEntity rCenter) async {
    final rCenterCollection =
        firebaseFirestore.collection(FirebaseConst.recyclingCenters);

    if (rCenter is! RCenterModel) {
      throw ArgumentError('Expected RCenterModel instance.');
    }

    // Convert the opening hours from entities to JSON
    List<Map<String, dynamic>> openingHoursJson =
        rCenter.openingHours?.map((dayOpeningHours) {
              if (dayOpeningHours is DayOpeningHoursModel) {
                return dayOpeningHours.toJson();
              } else {
                throw ArgumentError('Expected DayOpeningHoursModel instance.');
              }
            }).toList() ??
            [];

    // Merge JSONs
    final rCenterData = rCenter.toJson()
      ..addAll({'openingHours': openingHoursJson});

    // Check if the center already exists
    QuerySnapshot query = await rCenterCollection
        .where("latitude", isEqualTo: rCenter.latitude)
        .where("longitude", isEqualTo: rCenter.longitude)
        .get();

    if (query.docs.isEmpty) {
      DocumentReference newRCenterDoc =
          await rCenterCollection.add(rCenterData);
      return newRCenterDoc;
    } else {
      return query.docs.first.reference;
    }
  }

  @override
  Stream<List<RCenterEntity>> getSingleRCenter(String id) {
    final rCenterDocRef =
        firebaseFirestore.collection(FirebaseConst.recyclingCenters).doc(id);

    return rCenterDocRef.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return [RCenterModel.fromSnapshot(snapshot)];
      } else {
        return [];
      }
    });
  }

  @override
  Stream<List<RCenterEntity>> getRCenters() {
    final rCenterCollection =
        firebaseFirestore.collection(FirebaseConst.recyclingCenters);
    return rCenterCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RCenterModel.fromSnapshot(doc);
      }).toList();
    });
  }

  @override
  Future<void> saveRCenterAsFavorite(String uid, RCenterEntity rCenter) async {
    // Create or get existing center reference
    DocumentReference centerRef = await createNewRCenter(rCenter);

    // Get the reference of user's document and their favorites collection
    final userDocRef =
        firebaseFirestore.collection(FirebaseConst.users).doc(uid);
    final favRCenterCollection =
        userDocRef.collection(FirebaseConst.favoriteCenters);

    // Check if the center is already in the user's favorites
    QuerySnapshot existingFavorites = await favRCenterCollection
        .where('centerRef', isEqualTo: centerRef)
        .get();

    if (existingFavorites.docs.isEmpty) {
      await favRCenterCollection.add({
        'centerRef': centerRef,
        'savedDate': DateTime.now(),
      });
    } else {
      print('The center is already saved as a favorite.');
    }
  }

  @override
  Stream<List<RCenterEntity>> getUserSavedRCenters(String uid) {
    final favRCenterCollection = firebaseFirestore
        .collection(FirebaseConst.users)
        .doc(uid)
        .collection(FirebaseConst.favoriteCenters);

    // Listen to the snapshot changes and map them to a list of RCenterEntity
    return favRCenterCollection.snapshots().asyncMap((snapshot) async {
      List<RCenterEntity> centers = [];
      for (var doc in snapshot.docs) {
        DocumentReference centerRef = doc['centerRef'];
        DocumentSnapshot centerSnapshot = await centerRef.get();
        if (centerSnapshot.exists) {
          centers.add(RCenterModel.fromSnapshot(centerSnapshot));
        }
      }
      return centers;
    });
  }

  @override
  Future<void> removeUserSavedRCenter(String uid, RCenterEntity rCenter) async {
    final rCenterCollection =
        firebaseFirestore.collection(FirebaseConst.recyclingCenters);
    final userFavCollection = firebaseFirestore
        .collection(FirebaseConst.users)
        .doc(uid)
        .collection(FirebaseConst.favoriteCenters);

    // Find the recycling center document by latitude and longitude
    final rCenterQuery = await rCenterCollection
        .where('latitude', isEqualTo: rCenter.latitude)
        .where('longitude', isEqualTo: rCenter.longitude)
        .limit(1)
        .get();

    if (rCenterQuery.docs.isEmpty) {
      print('No recycling center found with the given latitude and longitude.');
      return;
    }

    // Get the document ID of the found recycling center
    final rCenterDocId = rCenterQuery.docs.first.id;

    // Find the user's favorite center reference by the recycling center's document ID
    final favCenterQuery = await userFavCollection
        .where('centerRef', isEqualTo: rCenterCollection.doc(rCenterDocId))
        .get();

    // Delete the favorite center
    for (var favDoc in favCenterQuery.docs) {
      await favDoc.reference.delete();
    }
  }
}
