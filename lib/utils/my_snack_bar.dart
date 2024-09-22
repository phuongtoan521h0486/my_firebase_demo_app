import 'package:flutter/material.dart';

void openSnackBar(context, snackMessage, color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      action: SnackBarAction(
        label: "Ok",
        onPressed: () {},
        textColor: Colors.white,
      ),
      content: Text(
        snackMessage.toString(),
        style: const TextStyle(fontSize: 14),
      ),
    ),
  );
}
