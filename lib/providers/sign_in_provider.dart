import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../strategies/sign_in_factory.dart';
import '../strategies/sign_in_strategy.dart';
import '../utils/map_sign_in_type.dart';


class SignInProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  MyUser? _myUser;
  MyUser? get myUser => _myUser;

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

  Future signOut(String type) async {
    await firebaseAuth.signOut();
    await SignInStrategyFactory.getStrategy(mapSignInType(type)).signOut();
    _isSignedIn = false;
    clearStoredData();
    notifyListeners();
  }

  Future clearStoredData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  Future<bool> checkUserExists() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_myUser!.uid)
        .get();
    return snapshot.exists;
  }

  Future getUserDataFromFirestore(uid) async {
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

  Future saveDataToFirestore() async {
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

  Future signIn(SignInType type) async {
    try {
      SignInStrategy strategy = SignInStrategyFactory.getStrategy(type);

      final userDetails = await strategy.signIn();

      if (userDetails == null) {
        _errorCode = "Sign-in cancel by user.";
        _hasError = true;
        notifyListeners();
        return;
      } else  {
        _myUser = userDetails;
        _hasError = false;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      _hasError = true;
      _errorCode = _handleFirebaseError(e);
      notifyListeners();
    }
    catch (e) {
      print(e.toString());
      _hasError = true;
      _errorCode = "Sign-in failed.";
      notifyListeners();
    }
  }

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case "account-exists-with-different-credential":
        return "Account already exists with another provider.";
      case "invalid-credential":
        return "Invalid credentials.";
      case "operation-not-allowed":
        return "Provider sign-in is not enabled in Firebase.";
      case "user-disabled":
        return "This user has been disabled.";
      default:
        return "Unexpected error: ${e.message}";
    }
  }
}
