import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  ImagePicker _picker = ImagePicker();
  
  Future<CameraResponse> takePicture() async {
    CameraResponse response = CameraResponse();
    XFile? picture;

    try {
      picture = await _picker.pickImage(source: ImageSource.camera);
    } on PlatformException catch (e) {
      response.error = 'It was not possible to access your camera. Error: $e';
    }
    
    response.file = (picture == null) ? null : File(picture.path);
    return response;
  }

  Future<CameraResponse> getFromGallery() async {
    CameraResponse response = CameraResponse();
    XFile? picture;
    
    try {
      picture = await _picker.pickImage(source: ImageSource.gallery);
    } on PlatformException catch (e) {
      response.error = 'It was not possible to access your gallery. Error: $e';
    }
     
    response.file = (picture == null) ? null : File(picture.path);
    return response;
  }
}

class CameraResponse {
  String? error;
  File? file;

  CameraResponse({ this.error, this.file });
}