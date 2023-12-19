// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

// class TestingPage extends StatefulWidget {
//   const TestingPage({super.key});

//   @override
//   State<TestingPage> createState() => _TestingPageState();
// }

// class _TestingPageState extends State<TestingPage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("DEMO"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             ElevatedButton(
//               onPressed: () {},
//               child: const Text('Hi'),
//             ),
//             OutlinedButton(
//               onPressed: () {},
//               child: const Text('Hi'),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:recycle_plus_app/core/constants/api.dart';

// final String apiKey = APIConst.googleMapAPIKey;

// class PlaceDetails {
//   final String name;
//   final String address;
//   final String phoneNumber;
//   final String openingHours;
//   final double distance;
//   final double estimatedArrivalTime;
//   final String imageUrl;
//   final double latitude;
//   final double longitude;

//   PlaceDetails({
//     required this.name,
//     required this.address,
//     required this.phoneNumber,
//     required this.openingHours,
//     required this.distance,
//     required this.estimatedArrivalTime,
//     required this.imageUrl,
//     required this.latitude,
//     required this.longitude,
//   });
// }

// Future<List<dynamic>> getNearbyPlacesWithKeyword(double lat, double lng, String keyword) async {
//   final String baseUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
//   final String location = '$lat,$lng';
//   final String radius = '5000'; // Define your desired search radius in meters

//   final Uri uri = Uri.parse('$baseUrl?location=$location&radius=$radius&keyword=$keyword&key=$apiKey');

//   final http.Response response = await http.get(uri);

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = json.decode(response.body);
//     return data['results'];
//   } else {
//     throw Exception('Failed to load nearby places');
//   }
// }

// Future<PlaceDetails> getPlaceDetails(String placeId, double userLat, double userLng) async {
//   final String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';

//   final Uri uri = Uri.parse('$baseUrl?place_id=$placeId&fields=name,formatted_address,formatted_phone_number,opening_hours,geometry,photos&key=$apiKey');

//   final http.Response response = await http.get(uri);

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = json.decode(response.body);
//     final Map<String, dynamic> result = data['result'];

//     final String name = result['name'];
//     final String address = result['formatted_address'];
//     final String phoneNumber = result['formatted_phone_number'] ?? 'Not available';
//     final String openingHours = result['opening_hours'] != null
//         ? result['opening_hours']['weekday_text'].join('\n')
//         : 'Not available';

//     final double destinationLat = result['geometry']['location']['lat'];
//     final double destinationLng = result['geometry']['location']['lng'];

//     final double distance = await getDistance(userLat, userLng, destinationLat, destinationLng);
//     final double estimatedArrivalTime = await getEstimatedArrivalTime(userLat, userLng, destinationLat, destinationLng);

//     final String imageUrl = result['photos'] != null && result['photos'].isNotEmpty
//         ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${result['photos'][0]['photo_reference']}&key=$apiKey'
//         : 'No image available';

//     return PlaceDetails(
//       name: name,
//       address: address,
//       phoneNumber: phoneNumber,
//       openingHours: openingHours,
//       distance: distance,
//       estimatedArrivalTime: estimatedArrivalTime,
//       imageUrl: imageUrl,
//       latitude: destinationLat,
//       longitude: destinationLng,
//     );
//   } else {
//     throw Exception('Failed to load place details');
//   }
// }

// Future<double> getDistance(double userLat, double userLng, double destinationLat, double destinationLng) async {
//   final String baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
//   final String origin = '$userLat,$userLng';
//   final String destination = '$destinationLat,$destinationLng';

//   final Uri uri = Uri.parse('$baseUrl?origin=$origin&destination=$destination&key=$apiKey');

//   final http.Response response = await http.get(uri);

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = json.decode(response.body);
//     final List<dynamic> routes = data['routes'];

//     if (routes.isNotEmpty) {
//       final Map<String, dynamic> leg = routes[0]['legs'][0];
//       final double distanceInMeters = leg['distance']['value'].toDouble();
//       return distanceInMeters;
//     } else {
//       throw Exception('No routes found');
//     }
//   } else {
//     throw Exception('Failed to load directions');
//   }
// }

// Future<double> getEstimatedArrivalTime(double userLat, double userLng, double destinationLat, double destinationLng) async {
//   final String baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
//   final String origin = '$userLat,$userLng';
//   final String destination = '$destinationLat,$destinationLng';

//   final Uri uri = Uri.parse('$baseUrl?origin=$origin&destination=$destination&key=$apiKey');

//   final http.Response response = await http.get(uri);

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = json.decode(response.body);
//     final List<dynamic> routes = data['routes'];

//     if (routes.isNotEmpty) {
//       final Map<String, dynamic> leg = routes[0]['legs'][0];
//       final int durationSeconds = leg['duration']['value'];
//       final double estimatedArrivalTime = durationSeconds / 60.0; // Convert to minutes

//       return estimatedArrivalTime;
//     } else {
//       throw Exception('No routes found');
//     }
//   } else {
//     throw Exception('Failed to load directions');
//   }
// }

// void main() async {
//   try {
//     final String keyword = 'recycle';
//     final double userLat = 5.2828; // User's current latitude
//     final double userLng = 100.2863; // User's current longitude
//     final List<dynamic> nearbyPlaces = await getNearbyPlacesWithKeyword(userLat, userLng, keyword);

//     if (nearbyPlaces.isEmpty) {
//       print('No nearby places found containing the keyword "$keyword".');
//     } else {
//       for (var result in nearbyPlaces) {
//         final PlaceDetails placeDetails = await getPlaceDetails(result['place_id'], userLat, userLng);

//         // Print detailed results including estimated arrival time
//         printDetailedResult(placeDetails);
//       }
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }

// void printDetailedResult(PlaceDetails placeDetails) {
//   print('Name: ${placeDetails.name}');
//   print('Address: ${placeDetails.address}');
//   print('Phone Number: ${placeDetails.phoneNumber}');
//   print('Opening Hours:\n${placeDetails.openingHours}');
//   print('Distance: ${placeDetails.distance} meters');
//   print('Estimated Arrival Time: ${placeDetails.estimatedArrivalTime.toStringAsFixed(2)} minutes');
//   print('Image URL: ${placeDetails.imageUrl}');
//   print('Latitude: ${placeDetails.latitude}');
//   print('Longitude: ${placeDetails.longitude}');
//   print('---');
// }

//

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:recycle_plus_app/core/constants/apis.dart';
// import 'package:recycle_plus_app/features/r_center/data/models/r_center_model.dart';

// void main() async {
//   const String keyword = 'recycle';
//   const double userLat = 5.2828;
//   const double userLng = 100.2863;

//   try {
//     final List<dynamic> places = await getNearbyPlacesWithKeyword(userLat, userLng, keyword);

//     for (var placeJson in places) {
//       final String placeId = placeJson['place_id'];
//       final Map<String, dynamic> detailsJson = await getPlaceDetails(placeId);

//       final RCenterModel recyclingCenter = RCenterModel.fromJson(detailsJson);

//       print('Name: ${recyclingCenter.name}');
//       print('Address: ${recyclingCenter.address}');
//       print('Contact No: ${recyclingCenter.contactNo}');
//       print('Open Now: ${recyclingCenter.openNow}');
//       print('Latitude: ${recyclingCenter.latitude}');
//       print('Longitude: ${recyclingCenter.longitude}');
//       print('Image URL: ${recyclingCenter.imageUrl}');
//       recyclingCenter.openingHours?.forEach((hours) {
//         print('Day: ${hours.dayOfWeek}');
//         print('Open Time: ${hours.openTime}');
//         print('Close Time: ${hours.closeTime}');
//       });
//       print('-----------------------------------');
//     }
//   } catch (e) {
//     print('An error occurred while fetching nearby recycling centers: $e');
//   }
// }

// Future<List<dynamic>> getNearbyPlacesWithKeyword(double lat, double lng, String keyword) async {
//   final String baseUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
//   final String location = '$lat,$lng';
//   final String radius = '5000';
//   final Uri uri = Uri.parse('$baseUrl?location=$location&radius=$radius&keyword=$keyword&key=${APIConst.googleMapAPIKey}');

//   final http.Response response = await http.get(uri);

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = json.decode(response.body);
//     return data['results'];
//   } else {
//     throw Exception('Failed to load nearby places');
//   }
// }

// // Make sure to replace 'YOUR_API_KEY' with your actual Google Maps API key.
// Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
//   final String baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
//   final Uri uri = Uri.parse('$baseUrl?placeid=$placeId&key=${APIConst.googleMapAPIKey}');

//   final http.Response response = await http.get(uri);

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> data = json.decode(response.body);
//     return data['result'];
//   } else {
//     throw Exception('Failed to load place details');
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_entity.dart';
import 'package:recycle_plus_app/features/learn/domain/entities/r_category_item_entity.dart';
import 'package:recycle_plus_app/features/learn/presentation/cubit/r_category_cubit.dart';
import 'package:image_picker/image_picker.dart';

// File? imageFile = await pickImage();
//                   if (imageFile != null) {
//                     BlocProvider.of<RCategoryCubit>(context).addNewRCategory(
//                         RCategoryEntity(name: 'Delete'), imageFile);
//                   }

// BlocProvider.of<RCategoryCubit>(context).getRCategories();

// BlocProvider.of<RCategoryCubit>(context).getSingleRCategory(id: 'phOTelf3A2uOcz5z6jwl');

// BlocProvider.of<RCategoryCubit>(context).addNewRCategoryItem(
//                       'phOTelf3A2uOcz5z6jwl',
//                       const RCategoryItemEntity(
//                           name: 'Plastic cup',
//                           recyclability: true,
//                           recyclingStepList: [
//                             'Step 1: Clean the bottle',
//                             'Step 2: Remove the label',
//                             'Step 3: Crush the bottle',
//                             'Step 4: Cap the bottle',
//                             'Step 5: Deposit in recycling bin'
//                           ]));

class TestingWidget extends StatelessWidget {
  const TestingWidget({super.key});

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // BlocProvider.of<RCategoryCubit>(context).addNewRCategoryItem(
                  //   'phOTelf3A2uOcz5z6jwl',
                  //   const RCategoryItemEntity(
                  //     name: 'Tissue Paper',
                  //     recyclability: true,
                  //     recyclingStepList: [
                  //       'Ensure it is clean and free from oils',
                  //       'Crumple and add to paper recycling if accepted',
                  //     ],
                  //   ),
                  // );
                },
                child: const Text('Upload Image'),
              ),
              BlocBuilder<RCategoryCubit, RCategoryState>(
                builder: (context, state) {
                  if (state is RCategoryStateLoading) {
                    return CircularProgressIndicator();
                  } else if (state is RCategoryItemStateSuccess) {
                    // Print the obtained items to the console
                    print(state.items.length);

                    return Text('Items fetched. Check console for details.');
                  } else if (state is RCategoryStateSuccess) {
                    // Print the obtained items to the console
                    print(state.categories);

                    return Text(
                        'Categories fetched. Check console for details.');
                  } else if (state is RCategoryStateError) {
                    return Text('Error: ${state.message}');
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayImageWidget extends StatelessWidget {
  final String imageUrl;

  const DisplayImageWidget({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(imageUrl);
  }
}
