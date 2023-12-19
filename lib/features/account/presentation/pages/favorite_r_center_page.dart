import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/day_opening_hours.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/get_user_favorite_r_center/get_user_favorite_cubit.dart';

class FavoriteRCenterPage extends StatelessWidget {
  const FavoriteRCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    late String uid;

    if (authState is Authenticated) {
      context
          .read<GetUserFavoriteRCenterCubit>()
          .fetchUserFavoritesRCenter(authState.uid);
      uid = authState.uid;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recycling Centers'),
      ),
      body:
          BlocBuilder<GetUserFavoriteRCenterCubit, GetUserFavoriteRCenterState>(
        builder: (context, state) {
          if (state is GetUserFavoriteRCenterLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetUserFavoriteRCenterLoaded) {
            return _buildFavoriteRecyclingCenterItems(uid, state);
          } else if (state is GetUserFavoriteRCenterError) {
            return const Center(child: Text('Oops! An error occurred.'));
          }
          return _noFavAddedMsg();
        },
      ),
    );
  }

  Widget _buildFavoriteRecyclingCenterItems(
      String uid, GetUserFavoriteRCenterLoaded getUserFavRcState) {
    final centers = getUserFavRcState.centers;

    if (centers.isEmpty) {
      return _noFavAddedMsg();
    }

    return Slidable(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: centers.length,
        itemBuilder: (context, index) {
          final RCenterEntity center = centers[index];
          return Slidable(
            key: ValueKey(center.id),
            closeOnScroll: true,
            startActionPane: ActionPane(
              extentRatio: 0.25,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context) {
                    context
                        .read<GetUserFavoriteRCenterCubit>()
                        .removeFromFavoriteRCenter(uid, center);
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Remove',
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 16.0,
              ),
              leading: const Icon(Icons.location_on),
              title: Text(
                center.name ?? 'Unknown',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: _buildOpenStatus(center.openingHours, center.openNow),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  PageConst.rcDetailsPage,
                  arguments: center,
                );
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 1,
            thickness: 1,
          );
        },
      ),
    );
  }

  Widget _noFavAddedMsg() {
    return const Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "You haven't added any favorites yet. Start exploring to find recycling centers to add to your favorites!",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenStatus(
      List<DayOpeningHoursEntity>? openingHours, bool? isOpenNow) {
    // Building the hours map
    Map<int, DayOpeningHoursEntity> hoursMap = {
      for (var hours in openingHours ?? []) hours.dayOfWeek!: hours
    };

    // Getting today's index
    int todayIndex = DateTime.now().weekday % 7;
    DayOpeningHoursEntity? todaysHours = hoursMap[todayIndex];

    if (isOpenNow == null || todaysHours == null) {
      if (todaysHours == null) {
        return const Text(
          'Not available',
          style: TextStyle(
            color: Colors.grey,
          ),
        );
      }
    }

    if (isOpenNow != null) {
      return Text(
        isOpenNow ? 'Open' : 'Closed',
        style: TextStyle(
          color: isOpenNow ? colorPrimary : Colors.red,
        ),
      );
    }

    return Container();
  }
}
