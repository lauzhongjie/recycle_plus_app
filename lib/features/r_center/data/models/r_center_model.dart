import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recycle_plus_app/core/constants/urls.dart';
import 'package:recycle_plus_app/features/r_center/data/models/day_opening_hours_model.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/day_opening_hours.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';

class RCenterModel extends RCenterEntity {
  final String? id;
  final String? name;
  final String? address;
  final String? vicinity;
  final String? contactNo;
  final bool? openNow;
  final List<DayOpeningHoursEntity>? openingHours;
  final double? distance;
  final double? estimatedArrivalTime;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  const RCenterModel({
    this.id,
    this.name,
    this.address,
    this.vicinity,
    this.contactNo,
    this.openNow,
    this.openingHours,
    this.distance,
    this.estimatedArrivalTime,
    this.imageUrl,
    this.latitude,
    this.longitude,
  }) : super(
          id: id,
          name: name,
          address: address,
          vicinity: vicinity,
          contactNo: contactNo,
          openNow: openNow,
          openingHours: openingHours,
          distance: distance,
          estimatedArrivalTime: estimatedArrivalTime,
          imageUrl: imageUrl,
          latitude: latitude,
          longitude: longitude,
        );

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        vicinity,
        contactNo,
        openNow,
        openingHours,
        distance,
        estimatedArrivalTime,
        imageUrl,
        latitude,
        longitude,
      ];

  // Convert data from Firebase snapshot
  factory RCenterModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>? ?? {};

    List<DayOpeningHoursModel> openingHours = [];
    if (snapshot['openingHours'] != null) {
      var hoursList = snapshot['openingHours'] as List;
      openingHours = hoursList
          .map(
              (e) => DayOpeningHoursModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }

    return RCenterModel(
      id: snap.id,
      name: snapshot['name'] as String?,
      address: snapshot['address'] as String?,
      contactNo: snapshot['contactNo'] as String?,
      openNow: snapshot['openNow'] as bool?,
      openingHours: openingHours,
      imageUrl: snapshot['imageUrl'] as String?,
      latitude: (snapshot['latitude'] as num?)?.toDouble(),
      longitude: (snapshot['longitude'] as num?)?.toDouble(),
    );
  }

  // Convert data from API
  factory RCenterModel.fromJson(
      Map<String, dynamic> detailsJson, Map<String, dynamic> directionsJson) {
    List<DayOpeningHoursModel> openingHours = [];
    if (detailsJson['opening_hours'] != null &&
        detailsJson['opening_hours']['periods'] != null) {
      openingHours = (detailsJson['opening_hours']['periods'] as List)
          .map((period) => DayOpeningHoursModel.fromJson(period))
          .toList();
    }

    String? getImageUrl(List<dynamic>? photos) {
      if (photos != null && photos.isNotEmpty) {
        String photoReference = photos.first['photo_reference'];
        return '${UrlConst.googlePlacePhotoBaseUrl}&photoreference=$photoReference';
      }
      return null;
    }

    return RCenterModel(
      name: detailsJson['name'],
      address: detailsJson['formatted_address'],
      vicinity: detailsJson['vicinity'],
      contactNo: detailsJson['formatted_phone_number'],
      openNow: detailsJson['opening_hours']?['open_now'],
      openingHours: openingHours,
      distance: directionsJson['distance'],
      estimatedArrivalTime: directionsJson['estimatedTime'],
      imageUrl: getImageUrl(detailsJson['photos']),
      latitude: detailsJson['geometry']['location']['lat'],
      longitude: detailsJson['geometry']['location']['lng'],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "address": address,
        "contactNo": contactNo,
        "openNow": openNow,
        "openingHours": openingHours,
        "imageUrl": imageUrl,
        "latitude": latitude,
        "longitude": longitude,
      };
}
