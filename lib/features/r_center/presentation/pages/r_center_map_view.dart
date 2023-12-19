import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
// import 'package:recycle_plus_app/core/widgets/search_bar.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/fetch_nearby_r_center/fetch_nearby_r_center_cubit.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:recycle_plus_app/features/r_center/presentation/widgets/custom_info_window_widget.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final Location _locationController = Location();
  Completer<GoogleMapController>? _mapController;
  LatLng? _currentP;
  StreamSubscription<LocationData>? _locationSubscription;

  // Permissions
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  // Fetching Nearby Recycling Centers
  LatLng? _lastFetchPosition;
  bool _firstTimeFetchNearby = true;

  // Custom Info Window
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapController = Completer<GoogleMapController>();
    _lastFetchPosition = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _currentP == null
        ? _buildLoadingWidget()
        : BlocBuilder<FetchNearbyRCenterCubit, FetchNearbyRCenterState>(
            builder: (context, state) {
              if (state is FetchNearbyRCenterLoading) {
                return _buildLoadingNearbyRCenterWidget();
              } else if (state is FetchNearbyRCenterLoaded) {
                _firstTimeFetchNearby = false;
                return _buildMapWidget(state.centers);
              } else if (state is FetchNearbyRCenterFailure) {
                return _buildErrorWidget(
                    'Error obtaining nearby recycling centers.\nPlease try again.');
              } else {
                return _buildLoadingNearbyRCenterWidget();
              }
            },
          );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildMapWidget(List<RCenterEntity> recyclingCenters) {
    // Create markers for each recycling center
    final Set<Marker> markers = recyclingCenters.map((center) {
      return Marker(
          markerId: MarkerId(center.name ?? 'Unknown'),
          position: LatLng(center.latitude ?? 0.0, center.longitude ?? 0.0),
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            _customInfoWindowController.addInfoWindow!(
              CustomInfoWindowWidget(rCenter: center),
              LatLng(center.latitude ?? 0.0, center.longitude ?? 0.0),
            );
          });
    }).toSet();

    return Stack(
      children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          initialCameraPosition: CameraPosition(
            target: _currentP!,
            zoom: 14,
          ),
          markers: markers,
          onMapCreated: onMapCreated,
          onTap: (position) {
            _customInfoWindowController.hideInfoWindow!();
          },
          onCameraMove: (position) {
            _customInfoWindowController.onCameraMove!();
          },
        ),
        CustomInfoWindow(
          controller: _customInfoWindowController,
          height: 210,
          width: 270,
          offset: 40,
        ),
        Positioned(
          right: 20.0,
          bottom: 30.0,
          child: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              _cameraToPosition(_currentP!);
            },
            backgroundColor: white,
            foregroundColor: black,
            child: const Icon(Icons.location_searching_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return FutureBuilder(
      future: _initLocationService(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Obtaining location...'),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return _buildErrorWidget(
              'Error obtaining location. Please try again.');
        } else {
          if (_currentP == null) {
            return _buildErrorWidget(
                'Please enable location service and grant permission in your device settings to use this feature.');
          } else {
            return _buildLoadingNearbyRCenterWidget();
          }
        }
      },
    );
  }

  Widget _buildLoadingNearbyRCenterWidget() {
    String loadingMessage = _firstTimeFetchNearby == true
        ? 'Obtaining nearby recycling centers...'
        : 'Updating nearby recycling centers...';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(loadingMessage),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMsg) {
    return RefreshIndicator(
      color: colorPrimary,
      key: UniqueKey(),
      onRefresh: () async {
        setState(() {});
        return Future.value();
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMsg,
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        '\nPull up to enable',
                        style: TextStyle(color: colorPrimary),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    if (_mapController != null && !_mapController!.isCompleted) {
      _mapController!.complete(controller);
      _customInfoWindowController.googleMapController = controller;
    }
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController!.future;
    double currentZoomLevel = await controller.getZoomLevel();

    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: currentZoomLevel,
    );

    controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> _initLocationService() async {
    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    try {
      LocationData locationData =
          await _locationController.getLocation().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          // Handle timeout
          throw Exception('Location request timed out');
        },
      );
      // If success
      setState(() {
        _currentP = LatLng(locationData.latitude!, locationData.longitude!);
      });
    } catch (e) {
      print('Error getting location: $e');
    }

    _locationSubscription = _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (!_mapController!.isCompleted && mounted) {
        // If the map is not yet initialized
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
        _updatePosition(
            currentLocation); // to trigger fetch nearby recycling centers
      } else {
        // If the map is already initialized
        _updatePosition(currentLocation);
      }
    });
  }

  void _updatePosition(LocationData currentLocation) {
    final newP = LatLng(currentLocation.latitude!, currentLocation.longitude!);

    // Check if user has moved more than 50 meters to update the current position
    if (mounted &&
        _mapController!.isCompleted &&
        shouldUpdatePosition(_currentP, currentLocation)) {
      setState(() {
        _currentP = newP;
      });
      _cameraToPosition(_currentP!);
    }

    // Check if user has moved more than 1000 meters to refresh nearby recycling centers
    if (_lastFetchPosition == null ||
        _calculateDistance(_lastFetchPosition!.latitude,
                _lastFetchPosition!.longitude, newP.latitude, newP.longitude) >
            1000) {
      fetchNearbyRecyclingCenters();
      _lastFetchPosition = newP;
    }
  }

  bool shouldUpdatePosition(LatLng? currentP, LocationData newLocation) {
    // If user move more than 50 meters only update the user location
    const double thresholdDistance = 50.0;

    if (currentP == null) {
      return true;
    }

    final double distance = _calculateDistance(
      currentP.latitude,
      currentP.longitude,
      newLocation.latitude!,
      newLocation.longitude!,
    );

    return distance > thresholdDistance;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double radiusOfEarth = 6371; // Earth's radius in kilometers
    double latDistance = _toRadians(lat2 - lat1);
    double lonDistance = _toRadians(lon2 - lon1);
    double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(lonDistance / 2) *
            sin(lonDistance / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radiusOfEarth * c * 1000; // convert to meters

    return distance;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  void fetchNearbyRecyclingCenters() {
    if (_currentP != null) {
      BlocProvider.of<FetchNearbyRCenterCubit>(context).getNearbyRCenter(
          lat: _currentP!.latitude,
          lng: _currentP!.longitude,
          keyword: 'recycle');
    }
  }
}
