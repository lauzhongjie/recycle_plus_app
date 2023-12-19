import 'package:equatable/equatable.dart';

class DayOpeningHoursEntity extends Equatable {
  final int? dayOfWeek;
  final DateTime? openTime;
  final DateTime? closeTime;

  const DayOpeningHoursEntity({
    this.dayOfWeek,
    this.openTime,
    this.closeTime,
  });

  @override
  List<Object?> get props => [
        dayOfWeek,
        openTime,
        closeTime,
      ];
}
