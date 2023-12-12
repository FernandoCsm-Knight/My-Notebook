import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notebook/common/database.dart';
import 'package:my_notebook/common/encryption_helper.dart';

import '../model/note.dart';

class NoteService {
  static EncryptionHelper encryptionHelper = EncryptionHelper();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<Note>> readNotes() async {
    List<Note> tmp = [];
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection(_uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .get();

    for (var doc in snapshot.docs) {
      Note note = Note.fromMap(doc.data());
      note.title = await encryptionHelper.decryptText(note.title);
      note.note = await encryptionHelper.decryptText(note.note);
      tmp.add(note);
    }

    return tmp;
  }

  Future<void> createNote({required String uuid, required String title}) async {
    Note note = Note(
        id: uuid,
        title: await encryptionHelper.encryptText(title),
        note: '',
        createdAt: DateTime.now(),
    );

    await db
        .collection(_uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .doc(note.id)
        .set(note.toMap());
  }

  Future<void> createFromNote({required Note note}) async {
    Map<String, dynamic> map = note.toMap();
    map['title'] = await encryptionHelper.encryptText(note.title);
    map['note'] = await encryptionHelper.encryptText(note.note);

    await db
        .collection(_uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .doc(note.id)
        .set(map);
  }

  Future<void> updateTitle({required String id, required String title}) async {
    await db
        .collection(_uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .doc(id)
        .update({'title': await encryptionHelper.encryptText(title)});
  }

  Future<void> updateNote({required String id, required String note}) async {
    await db
        .collection(_uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .doc(id)
        .update({'note': await encryptionHelper.encryptText(note)});
  }

  Future<void> deleteNote({required String id}) async {
    await db
        .collection(_uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .doc(id)
        .delete();
  }

  Future<void> deleteDoc() async {
    var snapshot = await db.collection(_uid).doc(Database.noteDoc).collection(Database.noteCollection).get();
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  }
}
