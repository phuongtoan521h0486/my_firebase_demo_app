import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_firebase_demo_app/strategies/sign_in_factory.dart';
import 'package:my_firebase_demo_app/strategies/sign_in_strategy.dart';
import 'package:twitter_login/twitter_login.dart';

import '../models/user.dart';

class XSignInStrategy implements SignInStrategy {
  final TwitterLogin xSignIn = TwitterLogin(
      apiKey: dotenv.env['X_API_KEY']!,
      apiSecretKey: dotenv.env['X_API_SECRET_KEY']!,
      redirectURI: dotenv.env['X_REDIRECT_URI']!);

  @override
  Future signIn() async {
    final result = await xSignIn.loginV2();

    if (result.status == TwitterLoginStatus.loggedIn) {
      final credential = await TwitterAuthProvider.credential(
        accessToken: result.authToken!,
        secret: result.authTokenSecret!,);

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        return MyUser(
          name: userCredential.user!.displayName,
          email: await FirebaseAuth.instance.currentUser!.email,
          imageUrl: userCredential.user!.photoURL!.replaceAll('_normal', '_bigger'),
          provider: SignInType.x.name,
          uid: userCredential.user!.uid,
        );
      }
    }
    return null;
  }

  @override
  Future signOut() async{
    // No need
  }
}
