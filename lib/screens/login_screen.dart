import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_firebase_demo_app/providers/internet_provider.dart';
import 'package:my_firebase_demo_app/providers/sign_in_provider.dart';
import 'package:my_firebase_demo_app/screens/home_screen.dart';
import 'package:my_firebase_demo_app/strategies/sign_in_factory.dart';
import 'package:my_firebase_demo_app/utils/my_snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../utils/my_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Map<SignInType, RoundedLoadingButtonController> controllers = {
    SignInType.google: RoundedLoadingButtonController(),
    SignInType.facebook: RoundedLoadingButtonController(),
    SignInType.x: RoundedLoadingButtonController(),
  };

  @override
  void dispose() {
    controllers.forEach((key, controller) {
      controller.reset();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 90, 40, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/logoGTV.png',
                            height: 80,
                            width: 80,
                          ),
                        ),
                        const Icon(Icons.close),
                        SvgPicture.asset(
                          'assets/images/logo-firebase.svg',
                          height: 60,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Image.asset('assets/images/login_background.png'),
                    const Text(
                      "Task Tracking",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Anton',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Take control of your work and life, effortlessly.",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Anton',
                        color: Colors.grey[600],
                      ),
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyButton(
                    controller: controllers[SignInType.google]!,
                    icon: FontAwesomeIcons.google,
                    text: const Text(
                      "Sign in with Google",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    color: Colors.red,
                    type: SignInType.google,
                    handleSignIn: handleSignIn,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyButton(
                    controller: controllers[SignInType.facebook]!,
                    icon: FontAwesomeIcons.facebook,
                    text: const Text(
                      "Sign in with Facebook",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    color: Colors.blue,
                    type: SignInType.facebook,
                    handleSignIn: handleSignIn,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyButton(
                    controller: controllers[SignInType.x]!,
                    icon: FontAwesomeIcons.xTwitter,
                    text: const Text(
                      "Sign in with X",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                    color: Colors.black,
                    type: SignInType.x,
                    handleSignIn: handleSignIn,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future handleSignIn(type) async {
    final signInProvider = context.read<SignInProvider>();
    final internetProvider = context.read<InternetProvider>();

    await internetProvider.checkInternetConnection();

    if (internetProvider.hasInternet == false) {
      openSnackBar(context, "check your Internet connection", Colors.red);
      controllers[type]!.reset();
      return;
    }
    await signInProvider.signIn(type);

    if (signInProvider.hasError) {
      openSnackBar(context, signInProvider.errorCode, Colors.red);
      controllers[type]!.reset();
      return;
    }

    final isExisted = await signInProvider.checkUserExists();
    if (isExisted) {
      await _handleExistingUser(signInProvider, type);
    } else {
      await _handleNewUser(signInProvider, type);
    }
  }

  Future _handleExistingUser(SignInProvider signInProvider, SignInType type) async {
    await signInProvider.getUserDataFromFirestore(signInProvider.myUser!.uid);
    await _saveUserData(signInProvider, type);
  }

  Future _handleNewUser(SignInProvider signInProvider, SignInType type) async {
    await signInProvider.saveDataToFirestore();
    await _saveUserData(signInProvider, type);
  }

  Future _saveUserData(SignInProvider signInProvider, SignInType type) async {
    await signInProvider.saveDataToSharedPreferences();
    await signInProvider.setSignIn();
    controllers[type]?.success();
    handleAfterSignIn();
  }

  handleAfterSignIn() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}


