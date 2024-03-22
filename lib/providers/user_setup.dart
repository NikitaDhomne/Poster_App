import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> userSetUp(String username, String email, String password) async {
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  FirebaseAuth _auth = FirebaseAuth.instance;
  String uid = _auth.currentUser!.uid.toString();
  await users.doc(uid).set(
      {'username': username, 'uid': uid, 'email': email, 'password': password});
  return;
}
