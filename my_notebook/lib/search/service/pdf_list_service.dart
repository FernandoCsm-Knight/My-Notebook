import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_notebook/common/storage/paths/storage_paths.dart';
import 'package:my_notebook/search/models/pdf_metadata.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:uuid/uuid.dart';

class PdfListService {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<File?> generatePdfThumbnail(File pdfFile) async {
    print('Generating thumbnail for ${pdfFile.path}');
    final doc = await PdfDocument.openData(await pdfFile.readAsBytes());
    final page = await doc.getPage(1);
    final pageImage = await page.render();
    doc.dispose();

    Image image = await pageImage.createImageDetached();

    final ByteData? byteData =
        await image.toByteData(format: ImageByteFormat.png);
    File? thumbnailFile = null;
    if (byteData != null) {
      final Uint8List imageBytes = byteData.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final String thumbnailPath = '${tempDir.path}/thumbnail.png';
      thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(imageBytes);
    }

    return thumbnailFile;
  }

  Future<void> addEvaluation(String pdfId, UserEvaluation evaluation) async {
    await firestore.collection(StoragePaths.allUsersPdf()).doc(pdfId).update({
      'evaluations': FieldValue.arrayUnion([
        {
          'userId': evaluation.userId,
          'userDisplayName': evaluation.userDisplayName,
          'userPhotoUrl': evaluation.userPhotoUrl,
          'userEmail': evaluation.userEmail,
          'date': evaluation.date.toIso8601String(),
          'text': evaluation.text,
        }
      ])
    });
  }

  Future<bool> updateEvaluation(
      String pdfId, UserEvaluation updatedEvaluation) async {
    var snapshot =
        await firestore.collection(StoragePaths.allUsersPdf()).doc(pdfId).get();
    var evaluations = snapshot.data()?['evaluations'];
    if (evaluations == null) {
      return false;
    }

    var updatedEvaluations = evaluations.map<UserEvaluation>((e) {
      if (e['userId'] == updatedEvaluation.userId) {
        return updatedEvaluation;
      } else {
        return UserEvaluation(
          userId: e['userId'],
          userDisplayName: e['userDisplayName'],
          userPhotoUrl: e['userPhotoUrl'],
          userEmail: e['userEmail'],
          date: DateTime.parse(e['date']),
          text: e['text'],
        );
      }
    }).toList();

    await firestore.collection(StoragePaths.allUsersPdf()).doc(pdfId).update({
      'evaluations': updatedEvaluations,
    });

    return true;
  }

  Future<bool> deleteEvaluation(String pdfId, String userId) async {
    var snapshot =
        await firestore.collection(StoragePaths.allUsersPdf()).doc(pdfId).get();
    var evaluations = snapshot.data()?['evaluations'];
    if (evaluations == null) {
      return false;
    }

    var updatedEvaluations =
        evaluations.where((e) => e['userId'] != userId).toList();

    await firestore.collection(StoragePaths.allUsersPdf()).doc(pdfId).update({
      'evaluations': updatedEvaluations,
    });

    return true;
  }

  Future<bool> uploadPdf(
      {required File pdfFile,
      required String title,
      required User user,
      void Function(double progress)? onProgress}) async {
    File? thumbnailFile = await generatePdfThumbnail(pdfFile);

    if (thumbnailFile == null) {
      print('Thumbnail generation failed');
      return false;
    }

    String id = Uuid().v1();

    var pdfUploadTask = storage
        .ref('${StoragePaths.allUsersPdf()}/$id/$title.pdf')
        .putFile(pdfFile);
    pdfUploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      if (onProgress != null) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      }
    });

    var pdfDownloadUrl = await (await pdfUploadTask).ref.getDownloadURL();

    var thumbnailUploadTask = storage
        .ref('${StoragePaths.allUsersPdf()}/$id/$title.png')
        .putFile(thumbnailFile);
    var thumbnailDownloadUrl =
        await (await thumbnailUploadTask).ref.getDownloadURL();

    await firestore.collection(StoragePaths.allUsersPdf()).doc(id).set({
      'userId': user.uid,
      'userDisplayName': user.displayName,
      'userPhotoUrl': user.photoURL,
      'userEmail': user.email,
      'pdfId': id,
      'title': title,
      'pdfUrl': pdfDownloadUrl,
      'thumbnailUrl': thumbnailDownloadUrl,
      'uploadDate': FieldValue.serverTimestamp(),
      'evaluations': [],
    });

    return true;
  }

  Future<List<PdfMetadata>> fetchPdfList() async {
    var querySnapshot =
        await firestore.collection(StoragePaths.allUsersPdf()).get();
    return querySnapshot.docs.map((doc) {
      var data = doc.data();
      return PdfMetadata(
        userId: data['userId'],
        userDisplayName: data['userDisplayName'],
        userPhotoUrl: data['userPhotoUrl'],
        userEmail: data['userEmail'],
        pdfId: data['pdfId'],
        title: data['title'],
        pdfUrl: data['pdfUrl'],
        thumbnailUrl: data['thumbnailUrl'],
        uploadDate: data['uploadDate'].toDate(),
        evaluations: data['evaluations'].map<UserEvaluation>((e) {
          return UserEvaluation(
            userId: e['userId'],
            userDisplayName: e['userDisplayName'],
            userPhotoUrl: e['userPhotoUrl'],
            userEmail: e['userEmail'],
            date: DateTime.parse(e['date']),
            text: e['text'],
          );
        }).toList(),
      );
    }).toList();
  }

  Future<bool> deletePdf(String pdfId) async {
    ListResult ref =
        await storage.ref('${StoragePaths.allUsersPdf()}/$pdfId/').listAll();
    for (var file in ref.items) {
      await file.delete();
    }

    await firestore.collection(StoragePaths.allUsersPdf()).doc(pdfId).delete();
    return true;
  }
}
