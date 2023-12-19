import 'package:recycle_plus_app/features/r_center/domain/entities/day_opening_hours.dart';

class DayOpeningHoursModel extends DayOpeningHoursEntity {
  const DayOpeningHoursModel({
    int? dayOfWeek,
    DateTime? openTime,
    DateTime? closeTime,
  }) : super(
          dayOfWeek: dayOfWeek,
          openTime: openTime,
          closeTime: closeTime,
        );

  // Convert data from Firebase snapshot map 
  factory DayOpeningHoursModel.fromMap(Map<String, dynamic> map) {
    return DayOpeningHoursModel(
      dayOfWeek: map['dayOfWeek'] as int?,
      openTime: map['openTime'] != null
          ? DateTime.parse(map['openTime'] as String)
          : null,
      closeTime: map['closeTime'] != null
          ? DateTime.parse(map['closeTime'] as String)
          : null,
    );
  }

  // Convert data from API
  factory DayOpeningHoursModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse time
    DateTime? parseTime(Map<String, dynamic>? timeJson) {
      if (timeJson != null && timeJson.containsKey('time')) {
        return DateTime(
          1970,
          1,
          1,
          int.parse(timeJson['time'].substring(0, 2)),
          int.parse(timeJson['time'].substring(2, 4)),
        );
      }
      return null;
    }

    // Safely access the 'open' and 'close' objects
    final openJson = json['open'] as Map<String, dynamic>?;
    final closeJson = json['close'] as Map<String, dynamic>?;

    return DayOpeningHoursModel(
      dayOfWeek: openJson?['day'],
      openTime: parseTime(openJson), // Safely parse open time
      closeTime: parseTime(closeJson), // Safely parse close time
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime?.toIso8601String(),
      'closeTime': closeTime?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [dayOfWeek, openTime, closeTime];
}
