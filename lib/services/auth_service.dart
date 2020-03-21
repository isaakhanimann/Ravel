import 'dart:async';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> signInAnonymously() async {
    AuthResult result = await _auth.signInAnonymously();
    return result.user.uid;
  }

  Future<String> getCurrentUid() async {
    FirebaseUser user = await _auth.currentUser();
    return user?.uid;
  }

  linkLoggedInUserWithGoogle() async {
    FirebaseUser loggedInUser = await _auth.currentUser();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await loggedInUser.linkWithCredential(credential);
  }

  linkLoggedInUserWithApple() async {
    FirebaseUser loggedInUser = await _auth.currentUser();
    final AuthorizationResult authorizationResult =
        await AppleSignIn.performRequests(
            [AppleIdRequest(requestedScopes: [])]);
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
        await loggedInUser.linkWithCredential(credential);
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

  Future<void> signOut() async {
    return _auth.signOut();
  }
}
