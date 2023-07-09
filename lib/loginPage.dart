import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sms_forward/app_retain_widget.dart';

import 'package:sms_forward/send_mail.dart';

String? email;
String? token;
var userC;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Timer? timer;
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: ((context) => const EmailSender()),
          ),
        );
      }
      return user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSignIn();
    Timer.periodic(const Duration(minutes: 45), (Timer t) {
      checktokenexpiredornot() == false ? refreshToken() : null;
    });
  }

  Future<bool> checktokenexpiredornot() async {
    User? user = FirebaseAuth.instance.currentUser;
    IdTokenResult tokenResult = await user!.getIdTokenResult();
    bool data = DateTime.now().isBefore(tokenResult.expirationTime!);
    return data;
  }

  Future<String?> refreshToken() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signInSilently();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    //SIGNING IN WITH CREDENTIAL & MAKING A USER IN FIREBASE  AND GETTING USER CLASS
    final userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;
    email = user!.email;
    token = googleSignInAuthentication.accessToken;
    userC = user;
    print(token);
    return googleSignInAuthentication.accessToken; // New refreshed token
  }

  checkSignIn() async {
    if (await googleSignIn.isSignedIn()) {
      refreshToken().then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: ((context) => const AppRetainWidget(
                  child: EmailSender(),
                )),
          ),
        );
      });
    } else {
      signInWithGoogle();
    }
  }

  // void signOut() async {
  //   await googleSignIn.signOut();
  //   await _auth.signOut();
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Loading........',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
