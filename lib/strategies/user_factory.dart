import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class MyUserFactory {
  static MyUser createUser(User user, String provider, {String? imageUrl}) {
    return MyUser(
      name: user.displayName,
      email: user.email,
      imageUrl: imageUrl ?? user.photoURL,
      provider: provider,
      uid: user.uid,
    );
  }
}
