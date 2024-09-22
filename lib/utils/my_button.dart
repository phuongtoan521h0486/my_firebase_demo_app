import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class MyButton extends StatelessWidget {
  RoundedLoadingButtonController controller;
  IconData icon;
  Text text;
  Color color;
  Function handleSignIn;
  MyButton(
      {super.key,
        required this.controller,
        required this.icon,
        required this.text,
        required this.color,
        required this.handleSignIn});

  @override
  Widget build(BuildContext context) {
    return RoundedLoadingButton(
      borderRadius: 25,
      width: MediaQuery.of(context).size.width * 0.8,
      color: color,
      controller: controller,
      successColor: color,
      elevation: 0,
      onPressed: () {
        handleSignIn();
      },
      resetAfterDuration: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
          const SizedBox(
            width: 15,
          ),
          text
        ],
      ),
    );
  }
}