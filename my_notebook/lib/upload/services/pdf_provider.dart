import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_notebook/common/storage/services/file_service.dart';

class PDFProvider {
  final String _uid;

  FileService _fileService = FileService();
  List<Reference> pdfFiles = [];

  PDFProvider({required String uid}) : _uid = uid;

  Future<void> refresh() async {
    List<Reference>? refs = await _fileService.readPdfs(uid: _uid);

    if (refs != null) {
      pdfFiles = refs;
    }
  }
}
