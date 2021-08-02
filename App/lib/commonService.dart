import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommonService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> get(String collection, String document, String field) async {
    String content = "";
    DocumentReference doc = db.collection(collection).doc(document);

    content = (await doc.get()).get(field);

    return content.replaceAll('\\n', '\n');
  }

  Future add(String collection, String document, final field) async {
    await db.collection(collection).doc(document).set(field);
  }

  Future deleteDocument(String collection, String document) async {
    await db.collection(collection).doc(document).delete();
  }
}

Future registration(String email, String password) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
      return 0;
    }
  } catch (e) {
    print(e);
  }
  return 1;
}

Future signIn(String email, String password) async {
  print('SingIn');
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
  }
}
