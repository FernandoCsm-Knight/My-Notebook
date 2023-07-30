import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notebook/notes/services/note_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
      }
      return e.code;
    }

    return null;
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'The account already exists for that email.';
      }
      return e.code;
    }

    return null;
  }

  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
      }
      return e.code;
    }

    return null;
  }

  Future<String?> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }

    return null;
  }

  Future<String?> deleteAccount({required String password}) async {
    try {
      await NoteService().deleteDoc();
      await _auth.signInWithEmailAndPassword(
        email: _auth.currentUser!.email!,
        password: password,
      );

      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }

    return null;
  }
}
