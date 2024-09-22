import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_firebase_demo_app/providers/sign_in_provider.dart';
import 'package:my_firebase_demo_app/screens/home_screen.dart';
import 'package:my_firebase_demo_app/screens/login_screen.dart';
import 'package:my_firebase_demo_app/utils/next_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    final signInProvider = context.read<SignInProvider>();
    super.initState();

    Timer(const Duration(seconds: 2), () {
      signInProvider.isSignedIn
          ? nextScreen(context, const HomeScreen())
          : nextScreen(context, const LoginScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logoGTV.png',
                height: 300,
                width: 300,
              ),
            ),
            const Text(
              "GTV Team",
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Anton',
              color: Color(0xFF08121E)),
            )
          ],
        )),
      ),
    );
  }
}
