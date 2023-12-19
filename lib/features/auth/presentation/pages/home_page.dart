import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';
import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/core/constants/tips_of_the_day_strings.dart';
import 'package:recycle_plus_app/core/widgets/login_to_view_overlay.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/cubit/user/get_single_user_cubit.dart';
import 'package:recycle_plus_app/features/auth/presentation/widgets/no_favorites_message.dart';
import 'package:recycle_plus_app/features/r_center/presentation/cubit/get_user_favorite_r_center/get_user_favorite_cubit.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/scan_entity.dart';
import 'package:recycle_plus_app/features/scan/presentation/cubit/scanning_record_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 40.0),
          child: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WelcomeMsg(),
                SizedBox(height: 30),
                TipsOfTheDay(),
                SizedBox(height: 30),
                RecentlyScannedItemSection(),
                SizedBox(height: 30),
                FavoriteRecyclingCenterSection(),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavoriteRecyclingCenterSection extends StatelessWidget {
  const FavoriteRecyclingCenterSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch records if the user is authenticated
    final authState = context.watch<AuthCubit>().state;
    if (authState is Authenticated) {
      // Scanning Records
      context.read<ScanningRecordCubit>().getAllUserScans(authState.uid);

      // Favorites Recycling Center Records
      context
          .read<GetUserFavoriteRCenterCubit>()
          .fetchUserFavoritesRCenter(authState.uid);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Favorite Recycling Centers',
              style: DefaultTextStyle.of(context).style.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                  ),
            ),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                return GestureDetector(
                  onTap: () {
                    if (authState is Authenticated) {
                      Navigator.pushNamed(
                          context, PageConst.favoriteRCenterPage);
                    } else {
                      Navigator.pushNamed(context, PageConst.signInPage);
                    }
                  },
                  child: const Text('Show all'),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BlocBuilder<GetUserFavoriteRCenterCubit,
                  GetUserFavoriteRCenterState>(
                builder: (context, getUserFavState) {
                  if (getUserFavState is GetUserFavoriteRCenterLoading) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: CircularProgressIndicator(),
                    );
                  } else if (getUserFavState is GetUserFavoriteRCenterLoaded) {
                    return _buildFavoriteRecyclingCenterItems(getUserFavState);
                  } else {
                    return const Center(child: Text('An error occured'));
                  }
                },
              );
            } else {
              return SizedBox(
                height: 120,
                child: buildLoginToViewOverlay(() {
                  Navigator.pushNamed(context, PageConst.signInPage);
                }),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildFavoriteRecyclingCenterItems(
      GetUserFavoriteRCenterLoaded getUserFavState) {
    final centers = getUserFavState.centers.take(3).toList();
    String msg =
        "You haven't added any favorites yet. Start exploring to find recycling centers to add to your favorites!";

    if (centers.isEmpty) {
      return NoFavoriteMessageHomeWidget(msg: msg);
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: centers.length,
      itemBuilder: (context, index) {
        final center = centers[index];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: darkGrey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            onTap: () {
              Navigator.pushNamed(
                context,
                PageConst.rcDetailsPage,
                arguments: center,
              );
            },
            leading: const Icon(Icons.location_on),
            title: Text(
              center.name ?? 'Unknown',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: _buildOpenStatus(center.openNow),
            trailing: const Icon(Icons.arrow_forward),
          ),
        );
      },
      separatorBuilder: ((context, index) => const SizedBox(height: 10)),
    );
  }

  Widget _buildOpenStatus(bool? isOpenNow) {
    if (isOpenNow == null) {
      return const Text(
        'Not available',
        style: TextStyle(
          color: Colors.grey,
        ),
      );
    }

    return Text(
      isOpenNow ? 'Open' : 'Closed',
      style: TextStyle(
        color: isOpenNow ? colorPrimary : Colors.red,
      ),
    );
  }
}

class RecentlyScannedItemSection extends StatelessWidget {
  const RecentlyScannedItemSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Recently Scanned Items',
              style: DefaultTextStyle.of(context).style.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                  ),
            ),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                return GestureDetector(
                  onTap: () {
                    if (authState is Authenticated) {
                      Navigator.pushNamed(
                          context, PageConst.savedObjectScanningPage);
                    } else {
                      Navigator.pushNamed(context, PageConst.signInPage);
                    }
                  },
                  child: const Text('Show all'),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BlocBuilder<ScanningRecordCubit, ScanningRecordState>(
                builder: (context, scanningState) {
                  if (scanningState is ScanningRecordLoading) {
                    return const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (scanningState is ScanningRecordLoaded) {
                    return SizedBox(
                      height: 120,
                      child: _buildRecentlyScannedItems(scanningState),
                    );
                  } else {
                    return const Center(child: Text('An error occured'));
                  }
                },
              );
            } else {
              return SizedBox(
                height: 120,
                child: buildLoginToViewOverlay(() {
                  Navigator.pushNamed(context, PageConst.signInPage);
                }),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildRecentlyScannedItems(ScanningRecordLoaded scanningState) {
    // Copy the scans to a new list to sort
    final List<ScanEntity> scans = List<ScanEntity>.from(scanningState.scans);

    // Sort the scans by date in descending order
    scans.sort((a, b) => b.scanDate!.compareTo(a.scanDate!));

    // Take the top 5 scans
    final recentScans = scans.take(5).toList();

    String msg =
        "You haven't scanned any items yet. Start scanning to track your recycling progress!";

    if (scans.isEmpty) {
      return NoFavoriteMessageHomeWidget(msg: msg);
    }

    return ListView.separated(
      itemCount: 5, // Always show 5 items
      scrollDirection: Axis.horizontal,
      separatorBuilder: (context, index) => const SizedBox(width: 16),
      itemBuilder: (context, index) {
        if (index < recentScans.length) {
          // Display the scanned item
          final scan = recentScans[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                PageConst.savedObjectScanningResultPage,
                arguments: scan,
              );
            },
            child: SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: scan.imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        } else {
          // Display a grey box if there are less than 5 scans
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                PageConst.scanningPage,
              );
            },
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Scan Now!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class TipsOfTheDay extends StatefulWidget {
  const TipsOfTheDay({
    super.key,
  });

  @override
  State<TipsOfTheDay> createState() => _TipsOfTheDayState();
}

class _TipsOfTheDayState extends State<TipsOfTheDay>
    with SingleTickerProviderStateMixin {
  late String currentTip;
  late String previousTip;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    currentTip = _getRandomTip();
    previousTip = currentTip;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  String _getRandomTip() {
    final Random random = Random();
    return recyclingTips[random.nextInt(recyclingTips.length)];
  }

  void _changeTip() {
    String newTip;
    do {
      newTip = _getRandomTip();
    } while (newTip == previousTip);

    setState(() {
      currentTip = newTip;
      previousTip = newTip;
    });

    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeTip,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colorPrimary,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Tips of the day:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: Text(
                    currentTip,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class WelcomeMsg extends StatelessWidget {
  const WelcomeMsg({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSingleUserCubit, GetSingleUserState>(
      builder: (context, state) {
        String userName = 'User'; // Default
        if (state is GetSingleUserLoaded) {
          userName = state.user.name ?? 'User';
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.headlineMedium!.fontSize,
                    ),
                children: [
                  const TextSpan(
                    text: 'Hi, ',
                    style: TextStyle(color: black),
                  ),
                  TextSpan(
                    text: '$userName!',
                    style: const TextStyle(color: colorPrimary),
                  ),
                ],
              ),
            ),
            Text(
              'Let\'s make a better world.',
              style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                    color: darkerGrey,
                  ),
            ),
          ],
        );
      },
    );
  }
}
