import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notebook/common/database.dart';
import 'package:uuid/uuid.dart';

import '../model/note.dart';

class NoteService {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<List<Note>> readNotes() async {
    List<Note> tmp = [];
    QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection(uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .get();

    for (var doc in snapshot.docs) {
      tmp.add(Note.fromMap(doc.data()));
    }

    return tmp;
  }

  Future<void> createNote({required String title}) async {
    Note note = Note(
        id: const Uuid().v1(),
        title: title,
        note: '',
        createdAt: DateTime.now());
    db
        .collection(uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .doc(note.id)
        .set(note.toMap());
  }

  Future<void> updateTitle({required String id, required String title}) async {
    db
        .collection(uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .doc(id)
        .update({'title': title});
  }

  Future<void> updateNote({required String id, required String note}) async {
    db
        .collection(uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .doc(id)
        .update({'note': note});
  }

  Future<void> deleteNote({required String id}) async {
    db
        .collection(uid)
        .doc(Database.noteDoc)
        .collection(Database.noteCollection)
        .doc(id)
        .delete();
  }

  Future<void> deleteDoc() async {
    db.collection(uid).doc(Database.noteDoc).collection(Database.noteCollection).get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }
    });
  }
}
