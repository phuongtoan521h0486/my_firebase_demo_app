import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_firebase_demo_app/strategies/sign_in_factory.dart';
import 'package:my_firebase_demo_app/strategies/sign_in_strategy.dart';

import '../models/user.dart';

class GoogleSignInStrategy implements SignInStrategy {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Future signIn() async {
    final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final User userDetails = (await FirebaseAuth.instance.signInWithCredential(credential)).user!;

      return MyUser(
        name: userDetails.displayName,
        email: userDetails.email,
        imageUrl: userDetails.photoURL,
        provider: SignInType.google.name,
        uid: userDetails.uid,
      );
    }
    return null;
  }

  @override
  Future signOut() async{
    await googleSignIn.signOut();
  }
}