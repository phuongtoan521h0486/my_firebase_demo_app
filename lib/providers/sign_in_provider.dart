import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class SignInProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  MyUser? _myUser;
  MyUser? get myUser => _myUser;

  // kiem tra dang nhap
  SignInProvider() {
    checkSignInUSer();
  }

  Future checkSignInUSer() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // login voi google
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        _errorCode = "Sign-in cancel by user.";
        _hasError = true;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final User userDetails =
          (await firebaseAuth.signInWithCredential(credential)).user!;

      _myUser = MyUser(
        name: userDetails.displayName,
        email: userDetails.email,
        imageUrl: userDetails.photoURL,
        provider: "GOOGLE",
        uid: userDetails.uid,
      );

      _hasError = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _hasError = true;
      switch (e.code) {
        case "account-exists-with-different-credential":
          _errorCode =
              "Account already exists with another provider. Please use that provider to sign in.";
          break;
        case "invalid-credential":
          _errorCode = "Invalid credentials. Please try again.";
          break;
        case "operation-not-allowed":
          _errorCode =
              "Google sign-in is not enabled. Please check your Firebase project settings.";
          break;
        case "user-disabled":
          _errorCode = "This user has been disabled. Please contact support.";
          break;
        default:
          _errorCode = "Unexpected error: ${e.message}";
      }
      notifyListeners();
    } catch (e) {
      _errorCode = "An unexpected error occurred: $e";
      _hasError = true;
      notifyListeners();
    }
  }

  // login voi facebook
  Future signInWithFacebook() async {
    final LoginResult result = await facebookAuth.login(permissions: ['email', 'public_profile']);
    final token = result.accessToken!.tokenString;

    final graphRespone = await http.get(Uri.parse(
        "https://graph.facebook.com/v20.0/me?fields=id,name,email,picture.type(large)&access_token=$token"));
    final profile = jsonDecode(graphRespone.body);

    if (result.status == LoginStatus.success) {
      try {
        final OAuthCredential credential = FacebookAuthProvider.credential(token);
        await firebaseAuth.signInWithCredential(credential);

        _myUser = MyUser(
          name: profile['name'],
          email: profile['email'],
          imageUrl: profile['picture']['data']['url'],
          provider: "FACEBOOK",
          uid: profile['id'],
        );

        _hasError = false;
        notifyListeners();

      } on FirebaseAuthException catch (e) {
        _hasError = true;
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "Account already exists with another provider. Please use that provider to sign in.";
            break;
          case "invalid-credential":
            _errorCode = "Invalid credentials. Please try again.";
            break;
          case "operation-not-allowed":
            _errorCode =
                "Facebook sign-in is not enabled. Please check your Firebase project settings.";
            break;
          case "user-disabled":
            _errorCode = "This user has been disabled. Please contact support.";
            break;
          default:
            _errorCode = "Unexpected error: ${e.message}";
        }
        notifyListeners();
      } catch (e) {
        _errorCode = "An unexpected error occurred: $e";
        _hasError = true;
        notifyListeners();
      }
    } else {
      _errorCode = "Login fail";
      _hasError = true;
      notifyListeners();
    }
  }

  // dang xuat
  Future userSignOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
    _isSignedIn = false;
    clearStoredData();
    notifyListeners();
  }

  // xoa thong tin dang nhap
  Future clearStoredData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  // kiem tra user co ton tai hay chua
  Future<bool> checkUserExists() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_myUser!.uid)
        .get();
    return snapshot.exists;
  }

  // lay du lieu tu Firestore bang uid
  Future<MyUser?> getUserDataFromFirestore(uid) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    return snapshot.exists
        ? MyUser(
            uid: snapshot['uid'],
            name: snapshot['name'],
            email: snapshot['email'],
            imageUrl: snapshot['image_url'],
            provider: snapshot['provider'],
          )
        : null;
  }

  // luu du lieu user vao firestore
  Future<void> saveDataToFirestore() async {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection("users").doc(_myUser!.uid);

    await reference.set({
      "name": _myUser!.name,
      "email": _myUser!.email,
      "uid": _myUser!.uid,
      "image_url": _myUser!.imageUrl,
      "provider": _myUser!.provider,
    });

    notifyListeners();
  }

  // luu du lieu vao share preferences
  Future saveDataToSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setString('name', _myUser!.name!);
    await sharedPreferences.setString('email', _myUser!.email!);
    await sharedPreferences.setString('uid', _myUser!.uid!);
    await sharedPreferences.setString('image_url', _myUser!.imageUrl!);
    await sharedPreferences.setString('provider', _myUser!.provider!);
    notifyListeners();
  }

  // lay du lieu tu share preferences
  Future getDataFromSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _myUser = MyUser(
      uid: sharedPreferences.getString('uid'),
      name: sharedPreferences.getString('name'),
      email: sharedPreferences.getString('email'),
      imageUrl: sharedPreferences.getString('image_url'),
      provider: sharedPreferences.getString('provider'),
    );
    notifyListeners();
  }
}
