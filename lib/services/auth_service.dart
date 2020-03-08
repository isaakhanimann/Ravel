import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<FirebaseUser> onAuthStateChanged() {
    return _auth.onAuthStateChanged;
  }

  Future<String> getCurrentUid() async {
    final user = await _auth.currentUser();
    return user?.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    final user = await _auth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }

  signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  signInWithApple({List<Scope> scopes = const []}) async {
    // 1. perform the sign-in request
    final AuthorizationResult authorizationResult =
        await AppleSignIn.performRequests(
            [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (authorizationResult.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = authorizationResult.credential;
        final oAuthProvider = OAuthProvider(providerId: 'apple.com');
        final credential = oAuthProvider.getCredential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        final authResult = await _auth.signInWithCredential(credential);
        final firebaseUser = authResult.user;
        if (scopes.contains(Scope.fullName)) {
          final updateUser = UserUpdateInfo();
          updateUser.displayName =
              '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
          await firebaseUser.updateProfile(updateUser);
        }
        break;
      case AuthorizationStatus.error:
        print(authorizationResult.error.toString());
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: authorizationResult.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
    }
  }

  Future<void> resetPassword({@required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<AuthResult> signInWithEmail(
      {@required String email, @required String password}) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<AuthResult> registerWithEmail(
      {@required String email, @required String password}) async {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<bool> deleteCurrentlyLoggedInUser() async {
    try {
      final user = await _auth.currentUser();
      // this also signs out the user
      await user.delete();
      return true;
    } catch (e) {
      print('Could not delete the user');
      print(e);
      return false;
    }
  }
}