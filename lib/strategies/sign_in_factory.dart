import 'package:my_firebase_demo_app/strategies/sign_in_strategy.dart';
import 'package:my_firebase_demo_app/strategies/x_sign_in_strategy.dart';

import 'facebook_sign_in_strategy.dart';
import 'google_sign_in_strategy.dart';

enum SignInType { google, facebook, x }

class SignInStrategyFactory {
  static SignInStrategy getStrategy(SignInType type) {
    switch (type) {
      case SignInType.google:
        return GoogleSignInStrategy();
      case SignInType.facebook:
        return FacebookSignInStrategy();
      case SignInType.x:
        return XSignInStrategy();
      default:
        throw UnsupportedError("Unsupported sign-in provider");
    }
  }
}


