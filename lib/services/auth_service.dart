import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<String> signInAnonymously() async {
    AuthResult result = await _auth.signInAnonymously();
    return result.user.uid;
  }

  Future<String> getCurrentUid() async {
    FirebaseUser user = await _auth.currentUser();
    return user?.uid;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }
}
