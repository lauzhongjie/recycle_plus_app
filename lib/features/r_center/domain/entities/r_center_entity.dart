import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/r_center/domain/entities/day_opening_hours.dart';

class RCenterEntity extends Equatable {
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

  const RCenterEntity({
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
  });

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
}
