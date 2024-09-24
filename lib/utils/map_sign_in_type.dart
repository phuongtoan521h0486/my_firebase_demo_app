import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../strategies/sign_in_factory.dart';

SignInType mapSignInType(String type) {
  switch (type) {
    case "google":
      return SignInType.google;
    case "facebook":
      return SignInType.facebook;
    case "x":
      return SignInType.x;
    default:
      return throw UnsupportedError("Unsupported sign-in provider");
  }
}

IconData getIconSignInType(String type) {
  switch (type) {
    case "google":
      return FontAwesomeIcons.google;
    case "facebook":
      return FontAwesomeIcons.facebook;
    case "x":
      return FontAwesomeIcons.xTwitter;
    default:
      return throw UnsupportedError("Unsupported sign-in provider");
  }
}