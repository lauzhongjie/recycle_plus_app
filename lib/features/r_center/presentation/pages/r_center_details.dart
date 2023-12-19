import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/image_strings.dart';
import 'package:recycle_plus_app/core/widgets/snackbar.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/day_opening_hours.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/get_user_favorite_r_center/get_user_favorite_cubit.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/save_as_favorite_r_center/save_as_favorite_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class RCenterDetailsPage extends StatefulWidget {
  final RCenterEntity rCenter;

  const RCenterDetailsPage({super.key, required this.rCenter});

  @override
  State<RCenterDetailsPage> createState() => _RCenterDetailsPageState();
}

class _RCenterDetailsPageState extends State<RCenterDetailsPage> {
  bool _favoritesFetched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Center Details'),
        actions: [
          IconButton(
            onPressed: () => _launchMap(),
            icon: const Icon(Icons.directions_car),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImage(),
              const SizedBox(height: 20.0),
              Center(
                child: Text(
                  widget.rCenter.name!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30.0),
              const Divider(color: darkGrey),
              const SizedBox(height: 20.0),
              _buildInfoTitle(Icons.location_on, 'Address'),
              const SizedBox(height: 5.0),
              Text(
                widget.rCenter.address!,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20.0),
              _buildInfoTitle(Icons.access_time, 'Operating Hours'),
              const SizedBox(height: 5.0),
              _buildOperatingHoursList(
                  widget.rCenter.openingHours, widget.rCenter.openNow),
              const SizedBox(height: 20.0),
              _buildInfoTitle(Icons.phone, 'Contact No.'),
              const SizedBox(height: 5.0),
              Text(
                widget.rCenter.contactNo ?? 'Not available',
              ),
              const SizedBox(height: 40.0),
              _buildSaveAsOrRemoveButton(),
              const SizedBox(height: 25.0),
            ],
          ),
        ),
      ),
    );
  }

  BlocBuilder<AuthCubit, AuthState> _buildSaveAsOrRemoveButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // If user is authenticated, check if center is saved as favorite
        if (authState is Authenticated) {
          if (!_favoritesFetched) {
            context
                .read<GetUserFavoriteRCenterCubit>()
                .fetchUserFavoritesRCenter(authState.uid);
            _favoritesFetched = true;
          }
          return BlocBuilder<GetUserFavoriteRCenterCubit,
              GetUserFavoriteRCenterState>(
            builder: (context, favoriteState) {
              if (favoriteState is GetUserFavoriteRCenterLoaded) {
                bool isFavorite = favoriteState.centers.any((center) =>
                    center.latitude == widget.rCenter.latitude &&
                    center.longitude == widget.rCenter.longitude);
                return isFavorite
                    ? _buildRemoveFromFavoriteButton(
                        context, authState, widget.rCenter)
                    : _buildSaveAsFavoriteButton(context, authState);
              } else if (favoriteState is GetUserFavoriteRCenterLoading) {
                return _buildLoadingButton();
              } else if (favoriteState is GetUserFavoriteRCenterError) {
                return _buildRetryButton(context, authState);
              }
              return Container();
            },
          );
        } else {
          return _buildSaveAsFavoriteDisabledButton(context);
        }
      },
    );
  }

  Container _buildImage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: widget.rCenter.imageUrl != null
          ? ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              child: CachedNetworkImage(
                imageUrl: widget.rCenter.imageUrl!,
                fit: BoxFit.cover,
                width: 300,
                height: 200,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 100,
                  color: colorPrimary,
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingButton() {
    return ElevatedButton(
      onPressed: () {},
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  ElevatedButton _buildRetryButton(
      BuildContext context, Authenticated authState) {
    return ElevatedButton(
      onPressed: () {
        context
            .read<GetUserFavoriteRCenterCubit>()
            .fetchUserFavoritesRCenter(authState.uid);
        setState(() {
          _favoritesFetched = false;
        });
      },
      child: const Padding(
        padding: EdgeInsets.all(18.0),
        child: Text('Retry'),
      ),
    );
  }

  ElevatedButton _buildSaveAsFavoriteButton(
      BuildContext context, Authenticated authState) {
    return ElevatedButton(
      onPressed: () {
        context
            .read<SaveAsFavoriteRCenterCubit>()
            .saveAsFavorite(authState.uid, widget.rCenter);
        setState(() {
          _favoritesFetched = false;
        });
      },
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Save as favorite',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5),
            Icon(Icons.favorite_border),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildRemoveFromFavoriteButton(
      BuildContext context, Authenticated authState, RCenterEntity rCenter) {
    return ElevatedButton(
      onPressed: () {
        context
            .read<GetUserFavoriteRCenterCubit>()
            .removeFromFavoriteRCenter(authState.uid, rCenter);
        setState(() {
          _favoritesFetched = false;
        });
      },
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remove from favorite',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5),
            Icon(Icons.favorite),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildSaveAsFavoriteDisabledButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please login to save favorites.'),
            action: SnackBarAction(
              label: 'Login',
              onPressed: () {
                Navigator.pushNamed(context, PageConst.signInPage);
              },
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: grey,
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Save as favorite',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5),
            Icon(Icons.favorite_border),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTitle(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: colorPrimary),
          ],
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Text(
              text,
              style: const TextStyle(
                color: colorPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpenStatus(bool isOpenNow) {
    return Text(
      isOpenNow ? '(Open)' : '(Closed)',
      style: TextStyle(
        color: isOpenNow ? colorPrimary : Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOperatingHoursList(
      List<DayOpeningHoursEntity>? openingHours, bool? isOpenNow) {
    Map<int, DayOpeningHoursEntity> hoursMap = {
      for (var hours in openingHours ?? []) hours.dayOfWeek!: hours
    };

    int todayIndex = DateTime.now().weekday % 7;

    List<Widget> hoursWidgets = List<Widget>.generate(7, (index) {
      DayOpeningHoursEntity? todaysHours = hoursMap[index];
      bool isToday = index == todayIndex;

      String dayString =
          DateFormat('EEEE').format(DateTime(2023, 1, index + 1));
      String hoursString = todaysHours != null
          ? '${DateFormat('hh:mm a').format(todaysHours.openTime!)} - ${DateFormat('hh:mm a').format(todaysHours.closeTime!)}'
          : 'Not available';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  dayString,
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isToday && todaysHours != null && isOpenNow != null) ...[
                  const SizedBox(width: 5.0),
                  _buildOpenStatus(isOpenNow),
                ],
              ],
            ),
            Text(
              hoursString,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    });

    return Column(children: hoursWidgets);
  }

  void _launchMap() {
    final latitude = widget.rCenter.latitude;
    final longitude = widget.rCenter.longitude;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: ClipOval(
                    child: Image.asset(
                      ImageConst.googleMapIcon,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: const Text(
                    'Open with Google Maps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Recommended for most users',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () => _launchMapApp('google', latitude!, longitude!),
                ),
                ListTile(
                  leading: ClipOval(
                    child: Image.asset(
                      ImageConst.wazeIcon,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: const Text(
                    'Open with Waze',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Use for real-time traffic',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () => _launchMapApp('waze', latitude!, longitude!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _launchMapApp(String mapApp, double latitude, double longitude) async {
    Uri uri;
    String placeName = widget.rCenter.name!;
    String address = widget.rCenter.address!;

    String combinedLocation = '$placeName, $address';
    String encodedLocation = Uri.encodeComponent(combinedLocation);

    if (mapApp == 'google') {
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encodedLocation');
    } else if (mapApp == 'waze') {
      uri = Uri.parse('waze://?ll=$latitude,$longitude&navigate=yes');
    } else {
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        showSnackbar(context, 'App not installed');
      }
    }
  }
}
