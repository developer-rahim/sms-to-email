import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sms_forward/loginPage.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://mail.google.com/']);

  Future<GoogleSignInAccount?> signIn() async {
    if (await googleSignIn.isSignedIn()) {
      return googleSignIn.currentUser;
    } else {
      return await googleSignIn.signIn();
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      //SIGNING IN WITH GOOGLE
      final GoogleSignInAccount? googleSignInAccount = await signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      //CREATING CREDENTIAL FOR FIREBASE
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      //SIGNING IN WITH CREDENTIAL & MAKING A USER IN FIREBASE  AND GETTING USER CLASS
      final userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      //CHECKING IS ON
      assert(!user!.isAnonymous);

      final User? currentUser = _auth.currentUser;
      assert(currentUser!.uid == user!.uid);

      if (user != null) {
        email = user.email;
        token = googleSignInAuthentication.accessToken;
        userC = user;
      }
      return user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String?> refreshToken() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signInSilently();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    //SIGNING IN WITH CREDENTIAL & MAKING A USER IN FIREBASE  AND GETTING USER CLASS
    final userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;
    email = user!.email;
    token = googleSignInAuthentication.accessToken;
    userC = user;

    return googleSignInAuthentication.accessToken; // New refreshed token
  }

  checkSignIn() async {
    if (await googleSignIn.isSignedIn()) {
      refreshToken();
    } else {
      signInWithGoogle();
    }
  }
}
