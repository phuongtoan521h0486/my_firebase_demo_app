import 'package:my_firebase_demo_app/strategies/sign_in_strategy.dart';

import 'facebook_sign_in_strategy.dart';
import 'google_sign_in_strategy.dart';

enum SignInType { google, facebook }

class SignInStrategyFactory {
  static SignInStrategy getStrategy(SignInType type) {
    switch (type) {
      case SignInType.google:
        return GoogleSignInStrategy();
      case SignInType.facebook:
        return FacebookSignInStrategy();
      default:
        throw UnsupportedError("Unsupported sign-in provider");
    }
  }
}

