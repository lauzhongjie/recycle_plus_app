import 'dart:typed_data';

class ScanningResult {
  final Uint8List imageData;
  final List<Map<String, dynamic>> detections;

  ScanningResult({
    required this.imageData,
    required this.detections,
  });
}
