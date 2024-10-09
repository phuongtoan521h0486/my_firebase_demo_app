import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'package:my_firebase_demo_app/strategies/sign_in_factory.dart';
import 'package:my_firebase_demo_app/strategies/sign_in_strategy.dart';

import '../models/user.dart';

class FacebookSignInStrategy implements SignInStrategy {
  final FacebookAuth facebookAuth = FacebookAuth.instance;

  @override
  Future signIn() async {
    final LoginResult result = await facebookAuth.login();
    final token = result.accessToken!.tokenString;

    final graphRespone = await http.get(Uri.parse(
        "https://graph.facebook.com/v20.0/me?fields=id,name,email,picture.type(large)&access_token=$token"));
    final profile = jsonDecode(graphRespone.body);

    if (result.status == LoginStatus.success) {
      final OAuthCredential credential =
      FacebookAuthProvider.credential(result.accessToken!.tokenString);
      await FirebaseAuth.instance.signInWithCredential(credential);

      return MyUser(
        name: profile['name'],
        email: profile['email'],
        imageUrl: profile['picture']['data']['url'],
        provider: SignInType.facebook.name,
        uid: profile['id'],
      );
    }
    return null;
  }

  @override
  Future signOut() async{
    await facebookAuth.logOut();
  }

}