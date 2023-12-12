import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_notebook/common/storage/paths/storage_paths.dart';

class ImageService {
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> upload({ required String uid, required String path }) async {
    File file = File(path);

    try {
      String ref = StoragePaths.userImage(uid);
      await _storage.ref(ref).putFile(file);
    } on FirebaseException {
      return'It was not possible to upload image.';
    }

    return null;
  }

  Future<String?> delete({ required String uid }) async {
    try {
      String ref = StoragePaths.userImage(uid);
      await _storage.ref(ref).delete();
    } on FirebaseException {
      return 'It was not possible to delete image.';
    }

    return null;
  }

  Future<String?> update({ required String uid, required String path }) async {
    String? error = await delete(uid: uid);
    if (error != null) {
      return error;
    }

    error = await upload(uid: uid, path: path);
    if (error != null) {
      return error;
    }

    return null;
  }

  Future<String?> read({ required String uid }) async {
    try {
      String ref = StoragePaths.userImage(uid);
      return _storage.ref(ref).getDownloadURL();
    } on FirebaseException {
      return null;
    }
  }
}
