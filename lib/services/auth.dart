import 'package:chat_app/screens/homescreen.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  // to check if user is signed in
  getCurrentUser() async {
    return auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);
    User? userDetails = result.user;
    String username = userDetails!.email!.replaceAll("@gmail.com", "");
    String firstLetter = username.substring(0, 1).toUpperCase();
    // Save user details to SharedPreferences
    await SharedPreferenceHelper()
        .saveUserDisplayName(userDetails.displayName!);
        await SharedPreferenceHelper()
        .saveUserEmail(userDetails.email!);
        await SharedPreferenceHelper()
        .saveUserId(userDetails.uid);
        await SharedPreferenceHelper()
        .saveUserName(username);

        await SharedPreferenceHelper()
        .saveUserImage(userDetails.displayName!);
    if (result != null) {
      Map<String, dynamic> userInfoMap = {
        "Name": userDetails.displayName,
        "Email": userDetails.email,
        "Image": userDetails.photoURL,
        "id": userDetails.uid,
        "username": username.toUpperCase(),
        "SearchKey": firstLetter,
      };
      await DatabaseMethods()
          .addUser(userInfoMap, userDetails.uid)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.white,
          content: Text("Registred Successfully",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ));

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                
                    )));
                    
      });
    }
    // You can save userInfomap to your database or use it as needed
  }
}
