import 'package:equatable/equatable.dart';
import 'package:recycle_plus_app/features/auth/domain/entities/user_entity.dart';
import 'package:recycle_plus_app/features/scan/domain/entities/detected_object_entity.dart';

class ScanEntity extends Equatable {
  final String? id;
  final UserEntity? user;
  final List<DetectedObjectEntity>? detectedObjectList;
  final String? imageUrl;
  final DateTime? scanDate;

  const ScanEntity({
    this.id,
    this.user,
    this.detectedObjectList,
    this.imageUrl,
    this.scanDate,
  });

  @override
  List<Object?> get props => [
        id,
        user,
        detectedObjectList,
        imageUrl,
        scanDate,
      ];
}
