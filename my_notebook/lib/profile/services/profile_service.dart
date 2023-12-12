import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notebook/common/database.dart';

class ProfileService {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> updatePhone({required String phone}) async {
    try {
      await _db.collection(_uid).doc(Database.profileDoc).update({ProfilePaths.phone: phone});
    } on Exception {
      return 'It was not possible to update phone number.';
    }

    return null;
  }

  Future<String?> updateImage() async {
    return null;
  }

  Future<String?> updateJob({ required String job }) async {
    try {
      await _db.collection(_uid).doc(Database.profileDoc).update({ProfilePaths.job: job});
    } on Exception {
      return 'It was not possible to update job.';
    }

    return null;
  }

  Future<String?> updatebirthday({required String birthday}) async {
    try {
      await _db.collection(_uid).doc(Database.profileDoc).update({ProfilePaths.birthday: birthday});
    } on Exception {
      return 'It was not possible to update birth day.';
    }

    return null;
  }

  Future<Map<String, dynamic>?> get profile async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _db.collection(_uid).doc(Database.profileDoc).get();
    return doc.data();
  }
}

class ProfilePaths {
  static const String job = 'job';
  static const String phone = 'phone';
  static const String birthday = 'birthday';
}

