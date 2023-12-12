
import 'dart:io';

import 'package:file_picker/file_picker.dart';

class PdfService {
  static Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      try {
        if(result.files.single.path != null) 
          return File(result.files.single.path!);
      } catch (e) {
        return null;
      }
    }

    return null;
  }
}
