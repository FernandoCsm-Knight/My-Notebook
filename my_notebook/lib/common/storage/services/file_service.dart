import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_notebook/common/storage/paths/storage_paths.dart';

class FileService {
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadPdf({
    required String uid,
    required File file,
    required Function(double) onProgress,
  }) async {
    try {
      String ref = StoragePaths.userPdf(uid) + file.path.substring(file.path.lastIndexOf('/')).replaceFirst('.pdf', '')
          + '?' + DateTime.now().toString().replaceAll(' ', '_') + '.pdf';
      UploadTask task = _storage.ref(ref).putFile(file);

      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress =
            snapshot.bytesTransferred / snapshot.totalBytes.toDouble();
        onProgress(progress);
      });

      await task;
    } on FirebaseException catch (e) {
      print("Error uploading PDF: $e");
      return 'Failed to upload PDF: ${e.message}';
    }

    return null;
  }

  Future<String?> deleteAllPdf({
    required String uid,
  }) async {
    String ref = StoragePaths.userPdf(uid);
    ListResult docs = await _storage.ref(ref).listAll();
    
    for(var doc in docs.items) {
      await doc.delete();
    }
    
    return null;
  }

  Future<String?> deletePdf({
    required String uid,
    required String path,
  }) async {
    try {
      String ref = StoragePaths.userPdf(uid) + path;
      await _storage.ref(ref).delete();
    } on FirebaseException catch (e) {
      print("Error deleting PDF: $e");
      return 'Failed to delete PDF: ${e.message}';
    }

    return null;
  }

  Future<String?> updatePdf({
    required String uid,
    required String path,
  }) async {
    String? error = await deletePdf(uid: uid, path: path);
    if (error != null) {
      return error;
    }

    error = await uploadPdf(uid: uid, file: File(path), onProgress: (double progress) {});
    if (error != null) {
      return error;
    }

    return null;
  }

  Future<Reference?> readPdf({
    required String uid,
    required String path,
  }) async {
    try {
      String ref = StoragePaths.userPdf(uid) + path;
      return _storage.ref(ref);
    } on FirebaseException catch (e) {
      print("Error reading PDF: $e");
      return null;
    }
  }

  Future<List<Reference>?> readPdfs({
    required String uid,
  }) async {
    try {
      String ref = StoragePaths.userPdf(uid);
      ListResult result = await _storage.ref(ref).listAll();
      return result.items;
    } on FirebaseException catch (e) {
      print("Error reading PDFs: $e");
      return null;
    }
  }
}
