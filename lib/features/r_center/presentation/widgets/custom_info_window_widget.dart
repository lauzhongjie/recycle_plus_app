import 'package:flutter/material.dart';
import 'package:recycle_plus_app/config/routes/app_routes_const.dart';

import 'package:recycle_plus_app/core/constants/colors.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/r_center_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomInfoWindowWidget extends StatelessWidget {
  final RCenterEntity rCenter;

  const CustomInfoWindowWidget({
    super.key,
    required this.rCenter,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          PageConst.rcDetailsPage,
          arguments: rCenter,
        );
      },
      child: Container(
        height: 210,
        width: 270,
        decoration: BoxDecoration(
          color: white,
          border: Border.all(color: grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 90,
                  width: 270,
                  decoration: BoxDecoration(
                    color: rCenter.imageUrl == null ? colorSecondary : null,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: rCenter.imageUrl != null
                      ? ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                          child: CachedNetworkImage(
                            imageUrl: rCenter.imageUrl!,
                            fit: BoxFit.cover,
                            width: 280,
                            height: 100,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          rCenter.name!,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${rCenter.distance! > 1000 ? '${(rCenter.distance! / 1000).toStringAsFixed(1)} km' : '${rCenter.distance} m'} | ${rCenter.estimatedArrivalTime?.round()} mins',
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  _buildOpenStatus(rCenter.openNow),
                  const SizedBox(height: 5.0),
                  Text(
                    rCenter.vicinity!,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenStatus(bool? isOpenNow) {
    if (isOpenNow == null) {
      return const Text(
        'Not available',
        style: TextStyle(
          color: darkGrey,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Text(
      isOpenNow ? 'Open' : 'Closed',
      style: TextStyle(
        color: isOpenNow ? colorSecondary : Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
