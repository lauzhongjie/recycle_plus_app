import 'package:recycle_plus_app/core/constants/apis.dart';

class UrlConst {
  static const String googlePlacePhotoBaseUrl =
      "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&key=${APIConst.googleMapAPIKey}";

  static const String googlePlaceNearbySearchBaseUrl =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json";

  static const String googlePlaceDetailsBaseUrl =
      "https://maps.googleapis.com/maps/api/place/details/json";

  static const String googlePlaceDirectionsBaseUrl =
      "https://maps.googleapis.com/maps/api/directions/json";
}
