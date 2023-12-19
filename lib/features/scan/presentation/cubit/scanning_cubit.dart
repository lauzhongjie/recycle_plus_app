import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'scanning_state.dart';

class ScanningCubit extends Cubit<ScanningState> {
  ScanningCubit() : super(ScanningInitial());

  Future<void> detectObj(XFile picture) async {
    emit(ScanningLoading());

    try {
      File image = File(picture.path);

      // Set the Flask API endpoint
      // Emulator
      // var uri = Uri.parse('http://127.0.0.1:5000/predict');

      // Wifi ip address
      // var uri = Uri.parse('http://192.168.100.27:5000/predict');

      // Data ip address
      var uri = Uri.parse('http://192.168.43.85:5000/predict');

      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      // Send the image to the Flask API and wait for the response
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var responseJson = jsonDecode(responseData);

        var detections = responseJson['predictions'] as List<dynamic>;
        List<Map<String, dynamic>> processedDetections = detections
            .map((detection) => detection as Map<String, dynamic>)
            .toList();

        // Decode the base64 string to Uint8List
        String base64Image = responseJson['image'];
        Uint8List decodedImage = base64Decode(base64Image);

        emit(ScanningLoaded({
          'imageData': decodedImage,
          'detections': processedDetections,
        }));
      } else {
        print('Failed to send image or get response');
        emit(ScanningFailure());
      }
    } catch (e) {
      print('Error occurred while detecting objects: $e');
      emit(ScanningFailure());
    }
  }
}
